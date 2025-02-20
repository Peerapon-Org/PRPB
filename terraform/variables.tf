# ==========================================================================================
# Global variables
# ==========================================================================================

variable "project" {
  type        = string
  description = "(Required) Name of the project"
}

variable "region" {
  type        = string
  description = "(Required) AWS region to deploy the resources"

  validation {
    condition     = can(regex("(af|ap|ca|eu|me|sa|us)-(central|north|(north(?:east|west))|south|south(?:east|west)|east|west)-\\d+", var.region))
    error_message = "Invalid AWS region. See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html for more details."
  }
}

variable "account" {
  type        = number
  description = "(Required) ID of the AWS account to deploy the resources"

  validation {
    condition     = can(regex("^\\d{12}$", var.account))
    error_message = "Invalid AWS account ID."
  }
}

variable "is_production" {
  type        = bool
  description = "(Optional) Flag to determine if the environment is production or not"
  default     = false
}

variable "environment" {
  type        = string
  description = "(Optional) Name of the environment"
  default     = "dev"
}

variable "branch" {
  type        = string
  description = "(Optional) Name of the GitHub branch you are working on"
}

# ==========================================================================================
# module: api
# ==========================================================================================

variable "api_definition" {
  type        = string
  description = "(Optional) Path to the API Gateway definition JSON file (relative to the Terraform root module directory)"
  default     = "assets/api/api.json"
}

variable "enable_account_logging" {
  type        = bool
  description = "(Optional) Enable account logging for the API Gateway"
}

# ==========================================================================================
# module: db
# ==========================================================================================

variable "blog_table_max_read_request_units" {
  type        = number
  description = "(Required) Maximum number of strongly consistent reads consumed per second for the main table before DynamoDB returns a ThrottlingException."
}

variable "blog_table_max_write_request_units" {
  type        = number
  description = "(Required) Maximum number of writes consumed per second for the main table before DynamoDB returns a ThrottlingException."
}

variable "tag_ref_table_max_read_request_units" {
  type        = number
  description = "(Required) Maximum number of strongly consistent reads consumed per second for the tag reference table before DynamoDB returns a ThrottlingException."
}

variable "tag_ref_table_max_write_request_units" {
  type        = number
  description = "(Required) Maximum number of writes consumed per second for the tag reference table before DynamoDB returns a ThrottlingException."
}

# ==========================================================================================
# module: cdn
# ==========================================================================================

variable "cloudfront_cache_policy" {
  type        = string
  description = "(Required) CloudFront cache policy name. See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html for more details."
}

variable "cloudfront_origin_request_policy" {
  type        = string
  description = "(Optional) CloudFront origin request policy name. See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html for more details."
  default     = null

  validation {
    condition     = var.cloudfront_origin_request_policy != "Managed-AllViewer"
    error_message = "S3 expects the origin's host and cannot resolve the distribution's host."
  }
}

variable "cloudfront_response_headers_policy" {
  type        = string
  description = "(Optional) CloudFront response header policy name. See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html for more details."
  default     = null
}

variable "cloudfront_function_source_code" {
  type        = string
  description = "(Optional) Path to the CloudFront function source code file (relative to the Terraform root module directory)"
  default     = "assets/cdn/addIndex.js"
}

variable "hosted_zone_name" {
  type        = string
  description = "(Required) The name of the hosted zone"
}

variable "app_sub_domain_name" {
  type        = string
  description = "(Optional) The sub domain name for the application"
  default     = null
}