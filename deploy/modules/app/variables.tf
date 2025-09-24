variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string
  default = "us-east-1"
}

variable "ENVIRONMENT_NAME" {
  description = "Name of the environment (e.g., dev, staging, prod)"
  type        = string
}

variable "PROJECT_NAME" {
  description = "Name of the project"
  type        = string
}

variable "VERSION" {
  description = "Version of the deployment"
  type        = string
}

variable "CLUSTER_STATE_BUCKET" {
  description = "S3 bucket that stores the core stack's Terraform state"
  type        = string
  default     = "terraform-rafiqi-personal"
}

variable "CLUSTER_STATE_REGION" {
  description = "Region of the S3 bucket that stores the core stack's Terraform state"
  type        = string
}

variable "CLUSTER_STATE_PROJECT_NAME" {
  description = "Project name used in the core stack's state key"
  type        = string
}