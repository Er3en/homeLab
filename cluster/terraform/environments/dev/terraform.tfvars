aws_region   = "eu-central-1"
environment  = "dev"
project      = "EKS-Deploy"
cluster_name = "eks-dev"
eks_version  = "1.29"

# Prefer your corporate IPs here instead of 0.0.0.0/0
public_access_cidrs = ["0.0.0.0/0"]

node_instance_types = ["t3.large"]
node_desired_size   = 2
node_min_size       = 2
node_max_size       = 4

vpc_cidr  = "10.20.0.0/16"
az_count  = 2