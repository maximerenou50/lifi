variable "vpc_id" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "ddb_table_id" {
  type = string
}
