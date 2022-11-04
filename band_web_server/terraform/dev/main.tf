# CloudFront関連のリソース
module "cloudfront" {
    source = "../base/00_cloudfront"
    
    region = var.region
    stage = var.stage
    prefix = var.prefix
    ip_set_cloudfront_waf = var.ip_set_cloudfront_waf
}

# GuardDuty関連のリソース
module "guardduty" {
    source = "../base/00_guardduty"
    
    region = var.region
    stage = var.stage
    prefix = var.prefix
}