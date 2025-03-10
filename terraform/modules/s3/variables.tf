variable "global_variables" {
  type = object({
    project       = string
    region        = string
    account       = string
    is_production = bool
    prefix        = string
    environment   = string
  })
  description = "Global variables for sharing across modules"
}