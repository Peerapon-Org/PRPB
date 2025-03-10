output "dynamodb_blog_table" {
  description = "DynamoDB blog table attributes"
  value = {
    name = aws_dynamodb_table.blog_table.name
    arn  = aws_dynamodb_table.blog_table.arn
  }
}

output "dynamodb_tag_ref_table" {
  description = "DynamoDB tag reference table attributes"
  value = {
    name = aws_dynamodb_table.tag_ref_table.name
    arn  = aws_dynamodb_table.tag_ref_table.arn
  }
}