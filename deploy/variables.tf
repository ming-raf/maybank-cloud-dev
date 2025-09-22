variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string
  default = "ap-southeast-1"
}

variable "ENVIRONMENT_NAME" {
  description = "Name of the environment (e.g., dev, staging, prod)"
  type        = string
  # Default removed - will be provided by TF_VAR_ENVIRONMENT_NAME
}

variable "PROJECT_NAME" {
  description = "Name of the project"
  type        = string
  default = "argocd-eks"
}

variable "VERSION" {
  description = "Version of the deployment"
  type        = string
  default = "1.0"
}
