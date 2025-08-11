locals {
  name_prefix = lower(join("-", [var.project, var.environment]))

  bucket_name  = var.s3_bucket_name       != "" ? var.s3_bucket_name       : "${local.name_prefix}-tfstate"
  lock_tbl     = var.dynamodb_table_name  != "" ? var.dynamodb_table_name  : "${local.name_prefix}-tfstate-lock"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}