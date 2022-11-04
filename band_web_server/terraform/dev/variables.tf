variable "region" {
  description = "リージョン"
  default     = "ap-northeast-1"
}
 
variable "prefix" {
  description = "リソースのプレフィックス"
  default     = "ql_aws"
}
 
variable "stage" {
  description = "プロジェクトの開発ステージ"
  default     = "dev"
}

variable "ip_set_cloudfront_waf" {
  description = "WAFホワイトリスト用のIP-set"
}