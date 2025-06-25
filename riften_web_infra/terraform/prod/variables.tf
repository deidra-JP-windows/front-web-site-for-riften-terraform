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