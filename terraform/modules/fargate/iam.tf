resource "aws_iam_role" "this" {
  name               = "lifi"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Managed policy required for ECS Fargate tasks to run
data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicyAttach" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

# DynamoDB policy required by the application
data "aws_iam_policy_document" "ddb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = ["arn:aws:dynamodb:eu-central-1:139568758574:table/${var.ddb_table_id}"]
  }
}

resource "aws_iam_role_policy" "ddb" {
  name   = "ddb"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ddb.json
}
