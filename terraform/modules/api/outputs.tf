output "api" {
  value = {
    id  = aws_api_gateway_stage.api_stage.id
    url = aws_api_gateway_stage.api_stage.invoke_url
  }
}

output "api_key_id" {
  description = "API Gateway API Key ID"
  value       = aws_api_gateway_api_key.api_key.id
}