output "app_domain_name" {
  description = "Application domain name"
  value       = local.app_domain_name
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.s3_distribution.id
}