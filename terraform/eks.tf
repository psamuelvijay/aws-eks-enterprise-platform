# EKS Cluster — managed control plane
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = true

  # IAM Authenticator — maps cluster creator to system:masters automatically
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Managed node group — 2x t3.small, scales 1-3 for autoscaling demo
  eks_managed_node_groups = {
    demo = {
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Use latest Amazon Linux 2 EKS-optimised AMI
      ami_type = "AL2_x86_64"

      labels = {
        role = "worker"
      }

      tags = {
        Project = var.cluster_name
      }
    }
  }

  tags = {
    Project     = var.cluster_name
    Environment = "demo"
  }
}
