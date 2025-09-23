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
	bucket_name     = "maybank.rafiqi.example.com"
}

resource "aws_cloudfront_origin_access_control" "oac" {
	name                              = "${local.cloudfront_name}-oac"
	description                       = "OAC for ${aws_s3_bucket.site.bucket}"
	origin_access_control_origin_type = "s3"
	signing_behavior                  = "always"
	signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
	enabled             = true
	comment             = local.cloudfront_name
	default_root_object = "index.html"

	origin {
		domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
		origin_id                = "s3-origin-${aws_s3_bucket.site.id}"
		origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

		s3_origin_config {
			origin_access_identity = ""
		}
	}

	origin {
		domain_name = aws_lb.nlb.dns_name
		origin_id   = "nlb-origin"

		custom_origin_config {
			http_port              = 80
			https_port             = 443
			origin_protocol_policy = "https-only"
			origin_ssl_protocols   = ["TLSv1.2"]
		}
	}

	default_cache_behavior {
		target_origin_id       = "s3-origin-${aws_s3_bucket.site.id}"
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