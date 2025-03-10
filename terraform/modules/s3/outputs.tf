output "s3_origin_bucket" {
  description = "S3 origin bucket attributes"
  value = {
    id                          = aws_s3_bucket.origin_bucket.id
    bucket_regional_domain_name = aws_s3_bucket.origin_bucket.bucket_regional_domain_name
    bucket                      = aws_s3_bucket.origin_bucket.bucket
    arn                         = aws_s3_bucket.origin_bucket.arn
  }
}

output "s3_blog_assets_bucket" {
  description = "S3 blog assets bucket attributes"
  value = {
    id                          = aws_s3_bucket.blog_assets_bucket.id
    bucket_regional_domain_name = aws_s3_bucket.blog_assets_bucket.bucket_regional_domain_name
    bucket                      = aws_s3_bucket.blog_assets_bucket.bucket
    arn                         = aws_s3_bucket.blog_assets_bucket.arn
  }
}