# CloudFront関連のリソース
module "cloudfront" {
    source = "../00_modules/cloudfront"
    
    region = var.region
    env = var.env
    prefix = var.prefix
    ip_set_cloudfront_waf = var.ip_set_cloudfront_waf
    lambda_backend_url = var.lambda_backend_url
    auth_lambda_edge_arn = var.auth_lambda_edge_arn
}

# GuardDuty関連のリソース
module "guardduty" {
    source = "../00_modules/guardduty"
    
    region = var.region
    env = var.env
    prefix = var.prefix
}
