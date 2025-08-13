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
  default     = "prod"
}

variable "domain_name" {
  description = "プロジェクトのドメイン名"
  default     = "riften.info"
}

variable "sub_domain_name" {
  description = "プロジェクトのサブドメイン名"
  default     = "www.riften.info"
}

variable "ip_set_cloudfront_waf" {
  description = "WAFホワイトリスト用のIP-set"
}

# Lambda Function URL (APIバックエンド) を外部から指定
variable "lambda_backend_url" {
  description = "CloudFrontオリジンに設定するLambda Function URL (APIバックエンド)"
  type        = string
}

# Lambda@Edge認証LambdaのARN
variable "auth_lambda_edge_arn" {
  description = "CloudFrontのdefault_cache_behaviorに紐付けるLambda@Edge認証LambdaのARN (バージョン付き)"
  type        = string
  default     = ""
}
