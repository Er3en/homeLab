locals {
  name_prefix = lower(join("-", [var.project, var.environment]))

  # choose N AZs deterministically
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}