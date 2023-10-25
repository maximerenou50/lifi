resource "aws_dynamodb_table" "lifi" {
  name         = "lifi"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "id"
    type = "S"
  }
}
