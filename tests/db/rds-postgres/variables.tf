variable "aws_region" {
  default = "us-east-1"
}

variable "db_username" {
  description = "Username for RDS"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  default     = "mydb"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access the DB"
  default     = "0.0.0.0/0"
}
