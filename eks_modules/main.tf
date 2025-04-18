

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  igw_name = var.igw_name
}

module "subnets" {
  source = "./modules/subnets"

  vpc_id        = module.vpc.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  cluster_name    = var.cluster_name
  tags           = var.tags
}

module "nat" {
  source = "./modules/nat"

  public_subnet_id = module.subnets.public_subnet_ids[0]
  eip_name         = var.eip_name
  nat_gateway_name = var.nat_gateway_name
  tags             = var.tags
  igw_dependency   = module.vpc.igw_id
}

module "routable" {
  source = "./modules/routable"

  vpc_id               = module.vpc.vpc_id
  nat_gateway_id       = module.nat.nat_gateway_id
  igw_id               = module.vpc.igw_id
  private_subnet_ids   = module.subnets.private_subnet_ids
  public_subnet_ids    = module.subnets.public_subnet_ids
  private_route_table_name = var.private_route_table_name
  public_route_table_name  = var.public_route_table_name
  tags                    = var.tags
}

module "eks" {
  source = "./modules/eks"

  iam_role_name         = var.iam_role_name
  iam_role_nodes_name   = var.iam_role_nodes_name
  cluster_name          = var.cluster_name
  subnet_ids            = concat(module.subnets.private_subnet_ids, module.subnets.public_subnet_ids)
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  node_group_name       = var.node_group_name
  private_subnet_ids    = module.subnets.private_subnet_ids
  capacity_type         = var.capacity_type
  instance_types        = var.instance_types
  desired_size          = var.desired_size
  max_size              = var.max_size
  min_size              = var.min_size
  max_unavailable       = var.max_unavailable
}