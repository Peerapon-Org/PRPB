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

variable "api_definition" {
  type        = string
  description = "(Required) Path to the API Gateway definition JSON file (relative to the Terraform root module directory)"
}

variable "enable_account_logging" {
  type        = bool
  description = "(Optional) Enable account logging for the API Gateway"
}

variable "blog_table_name" {
  type        = string
  description = "DynamoDB blog table name"
}

variable "tag_ref_table_name" {
  type        = string
  description = "DynamoDB tag reference table name"
}