# ec2/output.tf
output "ami_id" {
  value = aws_ami_from_instance.aws10_ami.id
}