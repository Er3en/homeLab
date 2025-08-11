provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project
    }
  }
}

# Useful identity for tagging/naming if needed later
data "aws_caller_identity" "current" {}

# Select AZs for subnet spread
data "aws_availability_zones" "available" {
  state = "available"
}