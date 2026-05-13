# 1. 원본 EC2 인스턴스 생성
resource "aws_instance" "aws10_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
  
  # 네트워크 정보 (01_network의 output 참조)
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  
  # 보안 그룹 설정
  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.ssh_sg_id,
    data.terraform_remote_state.network.outputs.http_sg_id
  ]

  # IAM 역할 연결 (02_iam의 output 참조)
  iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name

  # 초기 세팅 스크립트 (CodeDeploy, Docker 설치)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y ruby wget
              sudo apt install -y --reinstall ca-certificates
              sudo update-ca-certificates --fresh
              cd /home/ubuntu
              wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
              chmod +x ./install
              sudo ./install auto
              sudo systemctl enable codedeploy-agent
              sudo systemctl start codedeploy-agent

              ${file("${path.module}/user_data/docker-install.sh")}
            EOF

  tags = {
    Name = "${var.prefix}-instance"
  }
} # <--- 여기서 aws_instance 블록이 끝납니다.

# 2. 설치 완료를 위해 200초 대기
resource "null_resource" "aws10_delay" {
  provisioner "local-exec" {
    command = "sleep 200"
  }
  depends_on = [aws_instance.aws10_instance]
}

# 3. 설치가 완료된 인스턴스를 기반으로 AMI(이미지) 생성
resource "aws_ami_from_instance" "aws10_ami" {
  name                    = "${var.prefix}-instance-ami"
  source_instance_id      = aws_instance.aws10_instance.id
  snapshot_without_reboot = true
  depends_on              = [ null_resource.aws10_delay ]
  
  tags = {
    Name = "${var.prefix}-instance-ami"
  }
}