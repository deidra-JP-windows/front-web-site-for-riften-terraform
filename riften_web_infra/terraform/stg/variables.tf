variable "region" {
  description = "リージョン"
  default     = "ap-northeast-1"
}
 
variable "prefix" {
  description = "リソースのプレフィックス"
  default     = "riften-front-site"
}
 
variable "env" {
  description = "プロジェクトの開発ステージ"
  default     = "stg"
}

variable "domain_name" {
  description = "プロジェクトのドメイン名"
  default     = ""
}

variable "sub_domain_name" {
  description = "プロジェクトのサブドメイン名"
  default     = ""
}

variable "ip_set_cloudfront_waf" {
  description = "WAFホワイトリスト用のIP-set"
}

# Lambda Function URL (APIバックエンド) を外部から指定
variable "lambda_backend_url" {
  description = "CloudFrontオリジンに設定するLambda Function URL (APIバックエンド)"
  type        = string
}
