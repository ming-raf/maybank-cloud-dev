data "aws_caller_identity" "current" {}

# S3 Bucket
resource "aws_s3_bucket" "site" {
	bucket = local.bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "allow_cf_access" {
	statement {
		sid     = "AllowCloudFrontServicePrincipalRead"
		effect  = "Allow"
		actions = ["s3:GetObject"]

		resources = [
			"${aws_s3_bucket.site.arn}",
			"${aws_s3_bucket.site.arn}/*"
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
	bucket = aws_s3_bucket.site.id
	policy = data.aws_iam_policy_document.allow_cf_access.json
}

resource "aws_s3_bucket_public_access_block" "site" {
	bucket = aws_s3_bucket.site.id

	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "site" {
	bucket = aws_s3_bucket.site.id

	rule {
		object_ownership = "BucketOwnerPreferred"
	}
}

