resource "aws_iam_role" "aws10_ec2_role" {
  name = "${var.prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws10_ec2_ssm_attach" {
  role       = aws_iam_role.aws10_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws10_ec2_s3_attach" {
  role       = aws_iam_role.aws10_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "aws10_ec2_instance_profile" {
  name = "${var.prefix}-ec2-instance-profile"
  role = aws_iam_role.aws10_ec2_role.name
}


resource "aws_iam_role" "aws10_codedeploy_service_role" {
  name = "${var.prefix}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# Code Deploy Service Role
resource "aws_iam_role" "aws10_codedeploy_role" {
  role       = aws_iam_role.aws10_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.aws10_ec2_instance_profile.name
}
output "codedeploy_service_role_arn" {
  value = aws_iam_role.aws10_codedeploy_service_role.arn
}