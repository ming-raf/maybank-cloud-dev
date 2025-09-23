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
	cloudfront_name = "${var.PROJECT_NAME}-${var.ENVIRONMENT_NAME}-cdn"
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
	backend = "s3"
	config = {
		bucket = var.CORE_STATE_BUCKET
		key    = "${var.ENVIRONMENT_NAME}/.terraform/${var.CORE_STATE_PROJECT_NAME}.tfstate"
		region = var.CORE_STATE_REGION
	}
}

resource "aws_cloudfront_origin_access_control" "oac" {
	name                              = "${local.cloudfront_name}-oac"
	description                       = "OAC for ${data.terraform_remote_state.core.outputs.s3_bucket_name}"
	origin_access_control_origin_type = "s3"
	signing_behavior                  = "always"
	signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
	enabled             = true
	comment             = local.cloudfront_name
	default_root_object = "index.html"

	origin {
		domain_name              = data.terraform_remote_state.core.outputs.s3_bucket_regional_domain
		origin_id                = "s3-origin-${data.terraform_remote_state.core.outputs.s3_bucket_name}"
		origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

		s3_origin_config {
			origin_access_identity = ""
		}
	}

	origin {
		domain_name = data.terraform_remote_state.core.outputs.nlb_dns_name
		origin_id   = "nlb-origin"

		custom_origin_config {
			http_port              = 80
			https_port             = 443
			origin_protocol_policy = "http-only"
			origin_ssl_protocols   = ["TLSv1.2"]
		}
	}

	default_cache_behavior {
		target_origin_id       = "s3-origin-${data.terraform_remote_state.core.outputs.s3_bucket_name}"
		viewer_protocol_policy = "redirect-to-https"
		allowed_methods        = ["GET", "HEAD"]
		cached_methods         = ["GET", "HEAD"]

		forwarded_values {
			query_string = false
			cookies {
				forward = "none"
			}
		}
	}

	ordered_cache_behavior {
		path_pattern           = "/api/*"
		target_origin_id       = "nlb-origin"
		viewer_protocol_policy = "redirect-to-https"
		allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
		cached_methods         = ["GET", "HEAD", "OPTIONS"]

		forwarded_values {
			query_string = true
			cookies {
				forward = "all"
			}
		}
	}

	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}

	viewer_certificate {
		cloudfront_default_certificate = true
	}
}

data "aws_iam_policy_document" "allow_cf_access" {
	statement {
		sid     = "AllowCloudFrontServicePrincipalRead"
		effect  = "Allow"
		actions = ["s3:GetObject"]

		resources = [
			"${data.terraform_remote_state.core.outputs.s3_bucket_arn}",
			"${data.terraform_remote_state.core.outputs.s3_bucket_arn}/*"
		]

		principals {
			type        = "Service"
			identifiers = ["cloudfront.amazonaws.com"]
		}

		condition {
			test     = "StringEquals"
			variable = "AWS:SourceArn"
			values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn.id}"]
		}
	}
}

resource "aws_s3_bucket_policy" "allow_cf" {
	bucket = data.terraform_remote_state.core.outputs.s3_bucket_name
	policy = data.aws_iam_policy_document.allow_cf_access.json
}
