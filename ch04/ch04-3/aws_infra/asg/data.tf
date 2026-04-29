data "aws_vpc" "aws10_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-vpc"]
  }
}
data "aws_subnet" "aws10_private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-private-subnet-*"]
  }
}
data "aws_security_group" "aws10_ssh_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-ssh-sg"]
  }
}
data "aws_security_group" "aws10_http_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-http-sg"]
  }
}
data "iam_instance_profile" "aws10_ec2_instance_profile" {
  filter {
    name   = "${var.prefix}-ec2-instance-profile"
  }
}
data "aws_ami" "aws10_instance_ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name   = "name"
    values = ["${var.prefix}-instance-ami"]
  }
}
data "aws_target_group" "aws10_alb_was_group" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-alb-was-group"]
  }
}