variable "AWS_REGION" {
  description = "The AWS region to deploy resources in"
  type        = string
  default = "ap-southeast-1"
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

variable "nlb_domain_name" {
  description = "Custom domain name to use for the NLB (e.g., api.example.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID that contains the domain"
  type        = string
}

variable "origin_tls_certificate_arn" {
  description = "ACM certificate ARN for the NLB TLS listener (region must match the NLB region)"
  type        = string
}

variable "nlb_dns_name" {
  description = "DNS name of the existing Network Load Balancer to use as CloudFront origin (e.g., my-nlb-123456.elb.ap-southeast-1.amazonaws.com)"
  type        = string
}
