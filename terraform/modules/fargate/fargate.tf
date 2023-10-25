resource "aws_ecs_cluster" "this" {
  name = "lifi"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions = jsonencode([
    {
      name      = "lifi"
      image     = "139568758574.dkr.ecr.eu-central-1.amazonaws.com/lifi:latest" # TODO: use sem versioning instead of latest
      cpu       = 256
      memory    = 512
      essential = true
      environment = [
        {
          name : "DDB_TABLE_ID",
          value : var.ddb_table_id
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name,
          awslogs-region        = "eu-central-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "lifi"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "this" {
  name        = "lifi"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow traffic"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "lifi"
  retention_in_days = 1
}
