resource "aws_ecr_repository" "this" {
  name = "lifi"

  encryption_configuration {
    encryption_type = "AES256"
  }
}
