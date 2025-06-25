# S3バケットは先に手動で作成
terraform {
  backend "s3" {
    bucket  = "web-site-for-band-terraform-state"
    region  = "ap-northeast-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}