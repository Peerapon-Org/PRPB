output "s3_origin_bucket_name" {
  description = "S3 origin bucket name"
  value       = module.s3.s3_origin_bucket.bucket
}

output "s3_blog_assets_bucket_name" {
  description = "S3 blog assets bucket name"
  value       = module.s3.s3_blog_assets_bucket.bucket
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

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.distribution_id
}

output "blog_table_name" {
  description = "DynamoDB blog table name"
  value       = module.db.blog_table_name
}

output "tag_ref_table_name" {
  description = "DynamoDB tag reference table name"
  value       = module.db.tag_ref_table_name
}