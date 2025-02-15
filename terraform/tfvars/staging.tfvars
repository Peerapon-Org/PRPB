# ==========================================================================================
# module: api
# ==========================================================================================

api_definition         = "assets/api/api.json"

# ==========================================================================================
# module: db
# ==========================================================================================

blog_table_max_read_request_units     = 5
blog_table_max_write_request_units    = 5
tag_ref_table_max_read_request_units  = 5
tag_ref_table_max_write_request_units = 5

# ==========================================================================================
# module: cdn
# ==========================================================================================

cloudfront_cache_policy = "Managed-CachingOptimized"
hosted_zone_name        = "prpblog.com"
app_sub_domain_name     = "staging"
