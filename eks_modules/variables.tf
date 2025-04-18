# AWS Region
variable "aws_region" {
  description = "AWS region"
  type        = string
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

# Subnets Configuration
variable "private_subnets" {
  description = "List of private subnets"
  type = list(object({
    cidr = string
    az   = string
    name = string
  }))
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    cidr = string
    az   = string
    name = string
  }))
}

# NAT Gateway Configuration
variable "eip_name" {
  description = "Name tag for the Elastic IP"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway"
  type        = string
}

# Route Table Configuration
variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

# EKS Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role for EKS cluster"
  type        = string
}

variable "iam_role_nodes_name" {
  description = "Name of the IAM role for EKS nodes"
  type        = string
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster has private access"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster has public access"
  type        = bool
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "capacity_type" {
  description = "Capacity type for the EKS node group"
  type        = string
}

variable "instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
}

variable "max_unavailable" {
  description = "Maximum number of unavailable nodes during update"
  type        = number
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
}