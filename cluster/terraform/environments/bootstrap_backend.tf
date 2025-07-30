provider "aws" {
  region = "eu-central-1"
}

# resource "aws_s3_bucket" "tf_state" {
#   bucket = "my-terraform-state-bucket"
# }

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
