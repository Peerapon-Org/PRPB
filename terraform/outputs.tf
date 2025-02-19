output "s3_origin_bucket_name" {
  description = "S3 origin bucket name"
  value       = module.s3.s3_origin_bucket.bucket
}

output "api_key_id" {
  description = "API Gateway API Key ID"
  sensitive   = true
  value       = module.api.api_key_id
}

output "app_domain_name" {
  description = "Application domain name"
  value       = module.cdn.app_domain_name
}