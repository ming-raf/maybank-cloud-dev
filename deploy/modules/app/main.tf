terraform {
	required_providers {
		helm = {
			source  = "hashicorp/helm"
			version = "~> 2.13"
		}
		aws = {
			source  = "hashicorp/aws"
			version = "~> 6.10"
		}
	}
}

provider "aws" {
	region = var.AWS_REGION
}

variable "AWS_REGION" {
	type        = string
	description = "AWS region"
}

variable "ENVIRONMENT_NAME" {
	type        = string
	description = "Environment name (e.g. dev, test, prod)"
}

variable "CORE_STATE_BUCKET" {
	type        = string
	description = "S3 bucket holding the core stack state"
	default     = "terraform-rafiqi-personal"
}

variable "CORE_STATE_REGION" {
	type        = string
	description = "Region for the core state bucket"
	default     = "ap-southeast-1"
}

variable "CORE_STATE_PROJECT_NAME" {
	type        = string
	description = "Project name used in the core stack state key"
	default     = "maybank-cloud-dev"
}

variable "chart_name" {
	type        = string
	description = "Helm chart release name"
	default     = "sample-app"
}

variable "namespace" {
	type        = string
	description = "Kubernetes namespace to install into"
	default     = "sample-app"
}

variable "values_files" {
	type        = list(string)
	description = "Optional list of Helm values files (YAML) to apply"
	default     = []
}

locals {
	cluster_name = "maybank-cloud-${var.ENVIRONMENT_NAME}-eks"
}

# Discover EKS cluster endpoint and CA from the EKS module (same state file as other resources)
data "aws_eks_cluster" "this" {
	name = local.cluster_name
}

provider "helm" {
	kubernetes {
		host                   = data.aws_eks_cluster.this.endpoint
		cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
		token                  = data.aws_eks_cluster_auth.this.token
	}
}

resource "helm_release" "app" {
	name       = var.chart_name
	chart      = "${path.root}/../helm/${var.chart_name}"
	namespace  = var.namespace
	create_namespace = true
	dependency_update = true

	# Optional list of values files
	values = var.values_files

	# Ensure cluster exists first
	depends_on = [
			data.aws_eks_cluster.this
	]
}
