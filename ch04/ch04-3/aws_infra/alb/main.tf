resource "aws_lb" "aws10_alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.aws10_http_sg.id]
  subnets            = data.aws_subnets.aws10_public_subnets.ids
  tags = {
    Name = "${var.prefix}-alb"
  }
}

# was 대상그룹 생성
resource "aws_lb_target_group" "aws10_alb_was_group" {
  name     = "${var.prefix}-alb-was-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.aws10_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
  tags = {
    Name = "${var.prefix}-alb-was-target-group"
  }
}

resource "aws_lb_listener" "aws10_alb_listener" {
  load_balancer_arn = aws_lb.aws10_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Was 대상그룹 리스너 규칙 생성
resource "aws_lb_listener_rule" "aws10_alb_was_rule" {
  listener_arn = aws_lb_listener.aws10_alb_listener.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws10_alb_was_group.arn
  }
  condition {
    host_header {
      values = ["${var.prefix}-was.busanit.com"]
    }
  }
}



# jenkins 대상그룹 생성
resource "aws_lb_target_group" "aws10_alb_jenkins_group" {
  name     = "${var.prefix}-alb-jenkins-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.aws10_vpc.id
  health_check {
    path                = "/login"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
  tags = {
    Name = "${var.prefix}-alb-jenkins-target-group"
  }
}

# Jenkins 대상그룹 리스너 규칙 생성
resource "aws_lb_listener_rule" "aws10_alb_jenkins_rule" {
  listener_arn = aws_lb_listener.aws10_alb_listener.arn
  priority     = 25
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws10_alb_jenkins_group.arn
  }
  condition {
    host_header {
      values = ["${var.prefix}-jenkins.busanit.com"]
    }
  }
}
