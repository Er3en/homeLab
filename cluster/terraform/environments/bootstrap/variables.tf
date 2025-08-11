variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project or org slug used for naming"
  type        = string
  default     = "bootstrap"
}

variable "environment" {
  description = "Environment slug used for naming (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for TF state (leave blank to auto-generate)"
  type        = string
  default     = "eks-bucket-jarybski"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for TF state lock (leave blank to auto-generate)"
  type        = string
  default     = "eks-table"
}

variable "ecr_repos" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["eks"]
}

variable "enable_kms_encryption" {
  description = "If true, expect a KMS key ID for ECR & S3. If false, use SSE-S3."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key ARN to use when enable_kms_encryption = true"
  type        = string
  default     = null
}