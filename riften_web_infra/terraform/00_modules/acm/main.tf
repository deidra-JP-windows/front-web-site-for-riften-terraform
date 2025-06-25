provider "aws" {
  version = "~> 6.0"
  alias   = "alias_us_east_1"
  region  = "us-east-1"
}

# ACM 証明書の作成
resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.alias_us_east_1
  domain_name       = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
   
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Service = "${var.prefix}"
  }
}

resource "aws_route53_zone" "zone" {
  provider         = aws.alias_us_east_1
  name             = var.domain_name

  tags = {
    Service = "${var.prefix}"
  }
}

resource "aws_route53_record" "cloudfront_alias" {
  provider           = aws.alias_us_east_1
  zone_id            = aws_route53_zone.zone.id
  name               = var.domain_name
  type               = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_site.domain_name
    zone_id                = aws_cloudfront_distribution.web_site.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route 53 での DNS 検証レコード作成
resource "aws_route53_record" "cert_validation" {
  provider           = aws.alias_us_east_1
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

# ACM 証明書の検証完了を待機
resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
  provider                = aws.alias_us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
