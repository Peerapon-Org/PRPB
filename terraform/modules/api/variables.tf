variable "global_variables" {
  type = object({
    project       = string
    region        = string
    account       = number
    is_production = bool
    prefix        = string
    environment   = string
  })
  description = "Global variables for sharing across modules"
}

variable "dynamodb_blog_table" {
  type = object({
    name = string
    arn  = string
  })
  description = "DynamoDB blog table attributes"
}

variable "dynamodb_tag_ref_table" {
  type = object({
    name = string
    arn  = string
  })
  description = "DynamoDB tag reference table attributes"
}

variable "api_definition" {
  type        = string
  description = "(Optional) Path to the API Gateway definition JSON file (relative to the Terraform root module directory)"
  default     = "assets/api/api.json"
}

variable "enable_account_logging" {
  type        = bool
  description = "(Optional) Enable account logging for the API Gateway"
}