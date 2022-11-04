# S3バケットは先にコンソールを使って作成
# パブリックアクセスは拒否
terraform {
  backend "s3" {
    bucket  = ""
    region  = "ap-northeast-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}