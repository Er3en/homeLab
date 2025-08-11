variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "environment" {
  type        = string
  description = "Environment tag (dev/stage/prod)"
  default     = "dev"
}

variable "project" {
  type        = string
  description = "Project name for tags"
  default     = "EKS-Deploy"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "eks"
}

variable "eks_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.29"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "How many AZs to use (2 or 3 recommended)"
  default     = 2
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Allowed CIDRs for EKS public endpoint"
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" { 
  type = number
  default = 2 
}

variable "node_min_size" { 
  type = number 
  default = 2 
}

variable "node_max_size" { 
  type = number 
  default = 4 
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enable private endpoint access for EKS"
  default     = false
}
