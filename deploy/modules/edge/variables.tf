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