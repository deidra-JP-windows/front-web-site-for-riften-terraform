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


# Lambda@Edge認証Lambda ZIPファイルパス
variable "auth_lambda_zip_path" {
	description = "Lambda@Edge認証LambdaのZIPファイルパス (us-east-1用)"
	type        = string
}

# Lambda@Edge認証LambdaのIAMロールARN
variable "auth_lambda_role_arn" {
	description = "Lambda@Edge認証Lambdaに割り当てるIAMロールのARN (us-east-1)"
	type        = string
}

# トークン値
variable "auth_token" {
	description = "認証トークン値のダミー (Lambda@Edgeの環境変数)"
	type        = string
}
