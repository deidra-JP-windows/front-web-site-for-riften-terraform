provider "aws" {
  version = "~> 6.0"
  alias   = "alias_us_east_1"
  region  = "us-east-1"
}

# Lambda@Edge認証Lambda（トークン認証）
resource "aws_lambda_function" "auth_token" {
  filename         = var.auth_lambda_zip_path
  function_name    = "${var.env}-${var.prefix}-auth-token"
  role             = var.auth_lambda_role_arn
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  publish          = true
  source_code_hash = filebase64sha256(var.auth_lambda_zip_path)
  environment {
    variables = {
      AUTH_TOKEN = var.auth_token
    }
  }
  # Lambda@Edgeはus-east-1固定
  provider = aws.alias_us_east_1
}

# Lambda@Edge用のバージョン固定エイリアス
resource "aws_lambda_alias" "auth_token_live" {
  name             = "live"
  function_name    = aws_lambda_function.auth_token.function_name
  function_version = aws_lambda_function.auth_token.version
  provider         = aws.alias_us_east_1
}

# Lambda@Edge用のCloudFront実行許可
resource "aws_lambda_permission" "allow_cloudfront" {
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_token.arn
  principal     = "edgelambda.amazonaws.com"
  qualifier     = aws_lambda_function.auth_token.version
  provider      = aws.alias_us_east_1
}

resource "aws_s3_bucket" "info_site" {
  bucket = "${var.env}-${var.prefix}-info"
  tags = { Service = "${var.prefix}-info" }
}

resource "aws_s3_bucket" "front_site" {
  bucket = "${var.env}-${var.prefix}-front"
  tags = { Service = "${var.prefix}-front" }
}

resource "aws_s3_bucket" "data_store" {
  bucket = "${var.env}-${var.prefix}-data"
  tags = { Service = "${var.prefix}-data" }
}

resource "aws_s3_bucket_policy" "allow_access_from_OAC_info" {
  bucket = aws_s3_bucket.info_site.id
  policy = templatefile("${path.module}/template/policy.json", {
    bucket_arn = aws_s3_bucket.info_site.arn
    origin_access_control_id = aws_cloudfront_origin_access_control.info_site.id
  })
}
resource "aws_s3_bucket_public_access_block" "public_access_block_info" {
  bucket = aws_s3_bucket.info_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_OAC_front" {
  bucket = aws_s3_bucket.front_site.id
  policy = templatefile("${path.module}/template/policy.json", {
    bucket_arn = aws_s3_bucket.front_site.arn
    origin_access_control_id = aws_cloudfront_origin_access_control.front_site.id
  })
}
resource "aws_s3_bucket_public_access_block" "public_access_block_front" {
  bucket = aws_s3_bucket.front_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_OAC_data" {
  bucket = aws_s3_bucket.data_store.id
  policy = templatefile("${path.module}/template/policy.json", {
    bucket_arn = aws_s3_bucket.data_store.arn
    origin_access_control_id = aws_cloudfront_origin_access_control.data_store.id
  })
}
resource "aws_s3_bucket_public_access_block" "public_access_block_data" {
  bucket = aws_s3_bucket.data_store.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_OAC_logging" {
  bucket = aws_s3_bucket.cloudfront_logging.id
  policy = templatefile("${path.module}/template/policy.json", {
    bucket_arn = aws_s3_bucket.cloudfront_logging.arn
    origin_access_control_id = null
  })
}
resource "aws_s3_bucket_public_access_block" "public_access_block_logging" {
  bucket = aws_s3_bucket.cloudfront_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "web_site" {
  origin_access_control_origin_type = "s3"
  origin_access_control_name        = "${var.env}-${var.prefix}"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  s3_canonical_user_id              = aws_s3_bucket.info_site.owner
  tags = { Service = "${var.prefix}-info" }
}

resource "aws_cloudfront_origin_access_control" "front_site" {
  origin_access_control_origin_type = "s3"
  origin_access_control_name        = "${var.env}-${var.prefix}-front"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  s3_canonical_user_id              = aws_s3_bucket.front_site.owner
  tags = { Service = "${var.prefix}-front" }
}

resource "aws_cloudfront_origin_access_control" "data_store" {
  origin_access_control_origin_type = "s3"
  origin_access_control_name        = "${var.env}-${var.prefix}-data"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  s3_canonical_user_id              = aws_s3_bucket.data_store.owner
  tags = { Service = "${var.prefix}-data" }
}

# 365日後にオブジェクトを削除
resource "aws_s3_bucket_lifecycle_configuration" "web_site" {
  bucket = aws_s3_bucket.web_site.id

  rule {
    id      = "assets"
    status  = "Enabled"

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket" "cloudfront_logging" {
  provider = aws.alias_us_east_1
  count    = var.env == "prod" ? 1 : 0
  bucket = "${var.env}-${var.prefix}-cloudfront-logging"
  policy = templatefile("${path.module}"/template/logging_policy.json), {
    logging_bucket_arn = aws_s3_bucket.cloudfront_logging.arn
  }

  force_destroy = false
  versioning {
    enabled    = true
    mfa_delete = false
  }

  lifecycle_rule {
    id      = "assets"
    status  = "Enabled"

    expiration {
      days = "365" 
    }

    transition {
      days          = "93"
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = "1095" 
    }

    noncurrent_version_transition {
      days          = "365" 
      storage_class = "GLACIER"
    }
  }

  request_payer = "BucketOwner"
}

resource "aws_s3_bucket_public_access_block" "public_access_block_cloudfront_logging" {
  provider = aws.alias_us_east_1
  count    = var.env == "prod" ? 1 : 0
  bucket                  = aws_s3_bucket.cloudfront_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "web_site" {
  provider = aws.alias_us_east_1
  comment  = "${var.env}-${var.prefix}"
  enabled  = true
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.info_site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.info_site.id
    origin_access_control_id = aws_cloudfront_origin_access_control.info_site.id
  }
  origin {
    domain_name = aws_s3_bucket.front_site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.front_site.id
    origin_access_control_id = aws_cloudfront_origin_access_control.front_site.id
  }
  # Lambda Function URLオリジン（API Gatewayを使わずCloudFrontからのみアクセス）
  origin {
    domain_name = var.lambda_backend_url
    origin_id   = "lambda-backend"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
    }
    origin_shield {
      enabled              = false
    }
  }

  cache_behavior {
    path_pattern     = "/info/*"
    target_origin_id = aws_s3_bucket.info_site.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_alias.auth_token_live.arn
      include_body = false
    }
  }
  cache_behavior {
    path_pattern     = "/front/*"
    target_origin_id = aws_s3_bucket.front_site.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_alias.auth_token_live.arn
      include_body = false
    }
  }
  # Lambda Function URLへのcache_behavior例
  cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "lambda-backend"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress = true
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_alias.auth_token_live.arn
      include_body = false
    }
    # 必要に応じてオリジンリクエストポリシーやキャッシュポリシーを追加
    # origin_request_policy_id = aws_cloudfront_origin_request_policy.api_policy.id
    # cache_policy_id = aws_cloudfront_cache_policy.api_cache.id
  }
  # default_cache_behaviorはinfo_siteまたはfront_siteに割り当て

  # ...既存のlogging_config, custom_error_response, restrictions, tags, viewer_certificate, web_acl_id等はそのまま...

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logging.bucket_domain_name
    prefix          = "/${var.env}-${var.prefix}"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.web_site.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    # Lambda@Edge認証Lambdaをオリジンリクエストで紐付け
    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_alias.auth_token_live.arn
      include_body = false
    }
  }

  custom_error_response {
    error_code = "403"
    response_code = "200"
    response_page_path = "/error/403.html"
    error_caching_min_ttl = "0"
  }

  custom_error_response {
    error_code = "404"
    response_code = "200"
    response_page_path = "/error/404.html"
    error_caching_min_ttl = "0"
  }

  # 日本とマレーシア、アイルランド以外の地域からのアクセスを制限
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP", "MY", "IE"]
    }
  }

  tags = {
    Service = "${var.prefix}"
  }

  viewer_certificate {
    acm_certificate_arn             = var.env == "prod" ? module.acm.cloudfront_cert_arn : null
    cloudfront_default_certificate   = var.env != "prod"
    ssl_support_method               = var.env == "prod" ? "sni-only" : null
    minimum_protocol_version         = var.env == "prod" ? "TLSv1.2_2021" : null
  }

  web_acl_id = var.env == "prod" ? aws_wafv2_web_acl.wafv2_web_site[0].arn : 0
}

resource "aws_route53_record" "cloudfront_alias" {
  provider           = aws.alias_us_east_1
  count              = var.env == "prod" ? 1 : 0
  zone_id            = aws_route53_zone.zone.id
  name               = var.sub_domain_name
  type               = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_site.domain_name
    zone_id                = aws_cloudfront_distribution.web_site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_wafv2_ip_set" "web_site_ipset" {
  provider           = aws.alias_us_east_1
  count              = var.env == "prod" ? 1 : 0
  name               = "${var.env}-${var.prefix}-ip-set"
  description        = "${var.env}-${var.prefix}-ip-set"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ip_set_cloudfront_waf

  tags = {
    Service = "${var.prefix}"
  }
}

resource "aws_wafv2_web_acl" "wafv2_web_site" {
  provider    = aws.alias_us_east_1
  count       = var.env == "prod" ? 1 : 0
  name        = "managed-rule-wafv2-cf-web-site"
  description = "managed rule base"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # IPsetによるホワイトリスト
  rule {
    name     = "rule-1-ip-set"
    priority = 1

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.web_site_ipset.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockIpsExceptWhitelist"
      sampled_requests_enabled   = true
    }
  }
  
  # AWSのマネージドルール：　OWASPに含まれる基本的でリスクが高く一般的に発生するいくつかの脆弱性に対応する為のルール
  # ヘッダーやボディー、クッキー、リクエストパス、クエリパラメーターなどの検査
  # 現在20種類以上項目がある為、下記に詳細が記載されているデベロッパーガイドへのリンクを記載
  # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-crs
  rule {
    name     = "rule-2-CommonRuleSet"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafv2-cf-web-site-CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  # AWSのマネージドルール： ウェブサーバーまたはアプリケーションの管理用に確保されている URI パスの有無を検査
  rule {
    name     = "rule-3-AdminProtectionRuleSet"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafv2-cf-web-site-AdminProtectionRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWSのマネージドルール： 無効である可能性が高く脆弱性の悪用または発見に関連するリクエストパターンを検査
  # java固有のリクエストヘッダー検査（今回はJavaを使用しない）
  # Hostヘッダーにlocalhostを示すパターンがないか、リクエストのHTTPメソッドにPROPFINDがないかを検査
  # リクエストヘッダー、ボディ、URIパス、クエリパラメーターのLog4j脆弱性検査
  rule {
    name     = "rule-4-KnownBadInputsRuleSet"
    priority = 4

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafv2-cf-web-site-KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWSのマネージドルール： SQLインジェクション攻撃などに対するリクエストパターンを検査
  # サイト側から直接DBを見ることはないが(Lambdaを挟む)、悪意のあるユーザーの洗い出しに使用
  # クエリパラメーター、ボディー、クッキーヘッダーを検査
  rule {
    name     = "rule-5-SQLiRuleSet"
    priority = 5

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafv2-cf-web-site-KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWSのマネージドルール： Linux固有の脆弱性の悪用に関連するリクエストパターンを検査（LFI）
  # リクエストパス、クエリパラメーター、cookieヘッダーを検査
  rule {
    name     = "rule-6-LinuxRuleSet"
    priority = 6

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafv2-cf-web-site-LinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # AWSのマネージドルール： WAFが受け取ったIPアドレスを検査しBOTかどうか判断
  rule {
    name     = "rule-7-BotControlRuleSet"
    priority = 7

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "wafv2-cf-web-site-BotControlRuleSet"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Service = "${var.prefix}"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}
