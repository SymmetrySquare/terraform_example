data "aws_vpc" "aws10_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-vpc"]
  }
}
data "aws_subnets" "aws10_public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-public-subnet-*"]
  }
}
data "aws_security_group" "aws10_http_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-http-sg"]
  }
}