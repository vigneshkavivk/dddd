output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_name" {
  value = module.vpc.vpc_name
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_update_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  sensitive = true
}



output "db_endpoint" {
  description = "The RDS instance endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "db_identifier" {
  description = "The RDS instance identifier"
  value       = module.rds.db_identifier
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}
