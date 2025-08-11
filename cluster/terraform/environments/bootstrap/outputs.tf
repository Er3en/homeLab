output "tf_state_bucket" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "Name of the created S3 bucket for Terraform state"
}

output "tf_lock_table" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "Name of the DynamoDB table used for Terraform state locking"
}

output "ecr_repository_urls" {
  value       = { for k, r in aws_ecr_repository.repos : k => r.repository_url }
  description = "Map of ECR repository names to their URLs"
}