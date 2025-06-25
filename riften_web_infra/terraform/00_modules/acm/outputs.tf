output "cloudfront_cert_arn" {
  value       = aws_acm_certificate.cloudfront_cert.arn
  description = "The ARN of the ACM certificate for CloudFront"
}