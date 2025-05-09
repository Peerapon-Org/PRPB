variable "global_variables" {
  type = object({
    region        = string
    account       = string
    is_production = bool
    prefix        = string
    environment   = string
  })
  description = "Global variables for sharing across modules"
}