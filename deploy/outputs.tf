output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "s3_bucket_name" {
  description = "Name of the site S3 bucket"
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the site S3 bucket"
  value       = aws_s3_bucket.site.arn
}

output "s3_bucket_regional_domain" {
  description = "Regional domain name of the site S3 bucket"
  value       = aws_s3_bucket.site.bucket_regional_domain_name
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = aws_lb.nlb.dns_name
}

output "nlb_zone_id" {
  description = "Hosted zone ID of the Network Load Balancer"
  value       = aws_lb.nlb.zone_id
}