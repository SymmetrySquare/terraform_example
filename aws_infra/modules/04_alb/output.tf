# 1. ALB의 접속 주소 (나중에 이 주소로 웹사이트 접속 확인을 합니다)
output "alb_dns_name" {
  value       = aws_lb.aws10_alb.dns_name
  description = "The domain name of the load balancer"
}

# 2. 타겟 그룹 ARN (중요: Step 05 오토스케일링 그룹이 여기에 인스턴스를 붙여야 함)
output "alb_target_group_arn" {
  value       = aws_lb_target_group.aws10_atg.arn
  description = "The ARN of the Target Group to be used by ASG"
}

# 3. ALB 보안 그룹 ID (필요한 경우 다른 리소스에서 참조)
output "alb_security_group_id" {
  value       = data.aws_security_group.aws10_http_sg.id
}

# 4. (참고용) VPC ID
output "vpc_id" {
  value = data.aws_vpc.aws10_vpc.id
}