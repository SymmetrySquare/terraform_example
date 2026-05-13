# aws_infra/asg/main.tf

# 1. Launch Templete
resource "aws_launch_template" "aws10_was_lt" {
  name_prefix = "${var.prefix}-was-lt-"

  # data에서 찾은 최신 AMI ID 사용
  image_id = data.terraform_remote_state.was_ami.id
  instance_type = var.instance_type
  key_name = var.key_name

  iam_instance_profile {
    name = data.terraform_remote_state.ec2_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = "false"
    security_groups = [
      data.terraform_remote_state.network.outputs.was_sg_id
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-was-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Auto Scaling Group
resource "aws_autoscaling_group" "aws10_was_asg" {
  name = "${var.prefix}-was-asg"
  vpc_zone_identifier = data.aws_subnets.aws10_private_subnets.ids

  launch_template {
    id      = aws_launch_template.aws10_was_lt.id
    version = "$Latest"
  }

  target_group_arns = [data.terraform_remote_state.alb.outputs.alb_target_group_arn]

  min_size = "1"
  max_size = "3"
  desired_capacity = "2"

  health_check_type         = "EC2"
  health_check_grace_period = 300 

  tag {
    key                 = "Name"
    value               = "${var.prefix}-was-asg-instance"
    propagate_at_launch = true
  }
}
