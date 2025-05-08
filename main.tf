provider "aws" {
  region = var.region
}

# Stage 1: Create S3 Bucket and DynamoDB Table
resource "aws_s3_bucket" "tf_state2" {
  bucket = "backup-s3-tfstate2-${data.aws_caller_identity.current.account_id}"
  
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "tf_locks2" {
  name         = "terraform-state-locks2"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_caller_identity" "current" {}


# ... keep your existing module calls ...
module "vpc" {
  source = "./modules/vpc"

  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  private_subnets   = var.private_subnets
  public_subnets    = var.public_subnets
  allowed_ssh_cidr  = var.allowed_ssh_cidr
  allowed_udp_cidr  = var.allowed_udp_cidr
}

module "eks" {
  source = "./modules/eks"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.vpc.security_group_id
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  instance_types     = var.instance_types
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_desired_size  = var.node_desired_size
}

module "iam" {
  source = "./modules/iam"  # Path to your IAM module

  environment = var.environment
  aws_region  = var.aws_region
}

module "rds" {
  source = "./modules/rds"

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.security_group_id]
  monitoring_role_arn = module.iam.rds_monitoring_role_arn

  db_name            = var.db_name
  db_password        = var.db_password
  environment        = var.environment
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  db_username        = var.db_username
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [module.eks]

  triggers = {
    cluster_name = module.eks.cluster_name
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "null_resource" "argocd_install" {
  provisioner "local-exec" {
    command = <<-EOT
      if ! command -v helm &> /dev/null; then
        echo "Helm not found. Installing..."
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
      fi

      helm repo add argo https://argoproj.github.io/argo-helm
      helm repo update
      helm upgrade --install argocd argo/argo-cd \
        --namespace argocd \
        --create-namespace \
        --set server.service.type=LoadBalancer \
        --wait
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [null_resource.update_kubeconfig]
}

resource "null_resource" "wait_for_argocd" {
  depends_on = [null_resource.argocd_install]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for Argo CD LoadBalancer..."
      until kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" | grep -q "."; do
        sleep 5
      done

      echo "Waiting for Argo CD admin secret..."
      until kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; do
        sleep 5
      done
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

data "kubernetes_service" "argocd" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
  depends_on = [null_resource.wait_for_argocd]
}

data "kubernetes_secret" "argocd_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [null_resource.wait_for_argocd]
}

output "aws_account_id" {
  description = "The AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}