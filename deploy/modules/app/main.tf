terraform {
	required_providers {
		helm = {
			source  = "hashicorp/helm"
			version = "~> 3.0.2"
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

locals {
  name_prefix = "${var.PROJECT_NAME}-${var.ENVIRONMENT_NAME}"
}

data "terraform_remote_state" "cluster" {
	backend = "s3"
	config = {
		bucket = var.CLUSTER_STATE_BUCKET
		key    = "${var.ENVIRONMENT_NAME}/.terraform/${var.CLUSTER_STATE_PROJECT_NAME}.tfstate"
		region = var.CLUSTER_STATE_REGION
	}
}

data "terraform_remote_state" "core" {
	backend = "s3"
	config = {
		bucket = var.CORE_STATE_BUCKET
		key    = "${var.ENVIRONMENT_NAME}/.terraform/${var.CORE_STATE_PROJECT_NAME}.tfstate"
		region = var.CORE_STATE_REGION
	}
}

provider "helm" {
  kubernetes = {
		host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster.outputs.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "sample_app" {
	name       = "sample-app"
	chart      = "../../../helm/sample-app"
	namespace  = "sample_app"
	create_namespace = true
	dependency_update = true

	# Override chart values to wire EFS via YAML
	values = [
		yamlencode({
			storageClass = {
				enabled    = true
				name       = "efs-sc"
				parameters = {
					fileSystemId     = "${aws_efs_file_system.this.id}"
				}
			}
			persistence = {
				enabled          = true
				storageClassName = "efs-sc"
			}
		})
	]

  depends_on = [ aws_efs_file_system.this ]
}
