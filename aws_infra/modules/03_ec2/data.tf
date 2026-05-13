data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "aws10-terraform-state-bucket"
    key    = "network/terraform.tfstate" # 01_network가 아니라 network/ 입니다!
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "aws10-terraform-state-bucket"
    key    = "iam/terraform.tfstate"     # 02_iam이 아니라 iam/ 입니다!
    region = "ap-northeast-2"
  }
}