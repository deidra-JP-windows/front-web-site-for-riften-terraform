# 共通
variable "region" {}
variable "env" {}
variable "prefix" {}

variable "ip_set_cloudfront_waf" {}

# Lambda Function URL (APIバックエンド) を外部から指定
variable "lambda_backend_url" {
	description = "CloudFrontオリジンに設定するLambda Function URL (APIバックエンド)"
	type        = string
}
