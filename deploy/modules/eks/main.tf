terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10"
    }
  }
}

provider "aws" {
	region = var.AWS_REGION
}

locals {
  cluster_name = "maybank-cloud-${var.ENVIRONMENT_NAME}-eks"
}

data "terraform_remote_state" "core" {
	backend = "s3"
	config = {
		bucket = var.CORE_STATE_BUCKET
		key    = "${var.ENVIRONMENT_NAME}/.terraform/${var.CORE_STATE_PROJECT_NAME}.tfstate"
		region = var.CORE_STATE_REGION
	}
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.33"

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = data.terraform_remote_state.core.outputs.subnet_ids.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.terraform_remote_state.core.outputs.subnet_ids.private_subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  instance_types = ["t4g.micro"]
  ami_type       = "AL2023_ARM_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.ecr_readonly,
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
}

# Grant EKS access to IAM user 'fricheps'
data "aws_caller_identity" "current" {}

locals {
  fricheps_user_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/fricheps"
}

resource "aws_eks_access_entry" "fricheps" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.fricheps_user_arn
  type          = "STANDARD"

  depends_on = [
    aws_eks_cluster.this
  ]
}

resource "aws_eks_access_policy_association" "fricheps_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.fricheps.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.fricheps
  ]
}
