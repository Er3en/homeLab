terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Fill with your bucket/table/region (or use -backend-config at init time)
  backend "s3" {}
}