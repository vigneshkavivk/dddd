# AWS Region
aws_region = "us-east-1"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
vpc_name = "mASa-vPn"
igw_name = "igw"

# Subnets Configuration
private_subnets = [
  {
    cidr = "10.0.0.0/19"
    az   = "us-east-1a"
    name = "private-us-east-1a"
  },
  {
    cidr = "10.0.32.0/19"
    az   = "us-east-1b"
    name = "private-us-east-1b"
  }
]

public_subnets = [
  {
    cidr = "10.0.64.0/19"
    az   = "us-east-1a"
    name = "public-us-east-1a"
  },
  {
    cidr = "10.0.96.0/19"
    az   = "us-east-1b"
    name = "public-us-east-1b"
  }
]

# NAT Gateway Configuration
eip_name         = "nat"
nat_gateway_name = "nat"

# Route Table Configuration
private_route_table_name = "private"
public_route_table_name  = "public"

# EKS Configuration
cluster_name          = "velero-backup-cluster"
iam_role_name         = "eks-cluster-MASA1212"
iam_role_nodes_name   = "eks-node-group-nodessee"
endpoint_private_access = false
endpoint_public_access  = true
node_group_name       = "node-group-1"
capacity_type         = "ON_DEMAND"
instance_types        = ["t3.large"]
desired_size          = 1
max_size              = 1
min_size              = 0
max_unavailable       = 1

# Tags
tags = {
  Environment = "dev"
  Project     = "eks-demo"
}
