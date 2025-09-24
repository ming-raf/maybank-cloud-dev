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

variable "ORIGIN_REGION" {
  description = "AWS region of the origin resources (core stack), e.g. where S3 bucket and NLB are created"
  type        = string
  default     = "ap-southeast-1"
}

variable "CORE_STATE_BUCKET" {
  description = "S3 bucket that stores the core stack's Terraform state"
  type        = string
  default     = "terraform-rafiqi-personal"
}

variable "CORE_STATE_REGION" {
  description = "Region of the S3 bucket that stores the core stack's Terraform state"
  type        = string
  default     = "ap-southeast-1"
}

variable "CORE_STATE_PROJECT_NAME" {
  description = "Project name used in the core stack's state key"
  type        = string
  default     = "maybank-cloud-dev"
}