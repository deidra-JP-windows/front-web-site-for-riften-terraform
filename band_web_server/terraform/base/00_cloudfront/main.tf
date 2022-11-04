resource "aws_s3_bucket" "web_site" {
  bucket = "${var.stage}-${var.prefix}"

  tags = {
    Stage = ${var.stage}
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_OAI" {
  bucket = aws_s3_bucket.web_site.id
  policy = templatefile("${path.module}"/template/policy.json), {
    bucket_arn = aws_s3_bucket.web_site.arn
    origin_access_identity = aws_cloudfront_origin_access_identity.web_site.id
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.web_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "cloudfront_logging" {
  bucket = "${var.stage}-${var.prefix}-cloudfront-logging"
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
    enabled = true

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
  bucket                  = aws_s3_bucket.cloudfront_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "web_site" {
  comment = "${var.stage}-${var.prefix}"
}

resource "aws_cloudfront_distribution" "web_site" {
  comment             = "${var.stage}-${var.prefix}"
  origin {
    domain_name = aws_s3_bucket.web_site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.web_site.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_site.cloudfront_access_identity_path
    }
  }

  enabled             = true
  
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logging.bucket_domain_name
    prefix          = "/${var.stage}-${var.prefix}"
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
  }

  custom_error_response {
    error_code = "403"
    response_code = "200"
    response_page_path = "/"
    error_caching_min_ttl = "0"
  }

  custom_error_response {
    error_code = "404"
    response_code = "200"
    response_page_path = "/"
    error_caching_min_ttl = "0"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }

  tags = {
    Environment = "${var.stage}-${var.prefix}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = var.stage == "prod" ? aws_wafv2_web_acl.wafv2_web_site[0].arn : 0
}

provider "aws" {
  version = "~> 3.9"
  alias   = "alias-us-east-1"
  region  = "us-east-1"
}

resource "aws_wafv2_ip_set" "web_site_ipset" {
  provider           = aws.alias-us-east-1
  name               = "${var.stage}-${var.prefix}-ip-set"
  description        = "${var.stage}-${var.prefix}-ip-set"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.ip_set_cloudfront_waf

  tags = {
    Tag1 = "${var.stage}-${var.prefix}-ip-set"
  }
}

resource "aws_wafv2_web_acl" "wafv2_web_site" {
  provider    = aws.alias-us-east-1
  count       = var.stage == "prod" ? 1 : 0
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
            arn = aws_wafv2_web_acl.wafv2_web_site.arn
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
  # ヘッダーやボディー、クッキー、リクエストパス、クエリ引数などの検査
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
  # java固有のリクエストヘッダー検査（今回はJavaを使用しない為、割愛）
  # Hostヘッダーにlocalhostを示すパターンがないか、リクエストのHTTPメソッドにPROPFINDがないかを検査
  # リクエストヘッダー、コンテキスト、URIパス、クエリのLog4j脆弱性検査
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
  # クエリ、コンテキスト、ボディー、クッキーヘッダーを検査
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
  # リクエストパス、クエリ、cookieヘッダーを剣sな
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

  tags = {
    Stage = "${var.stage}-${var.prefix}-cloudfront-waf"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}