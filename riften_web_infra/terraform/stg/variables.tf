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