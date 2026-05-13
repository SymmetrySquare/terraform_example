output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.aws10_ec2_instance_profile.name
}
output "codedeploy_role_name" {
  value = aws_iam_role.aws10_codedeploy_role.name
}