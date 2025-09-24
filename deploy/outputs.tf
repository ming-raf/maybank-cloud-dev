output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.mariadb.address
}

output "rds_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = aws_db_instance.mariadb_replica.address
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN containing RDS master credentials"
  value       = aws_secretsmanager_secret.db_master.arn
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

output "bastion_instance_id" {
  description = "Instance ID of the SSM bastion"
  value       = aws_instance.bastion.id
}

output "bastion_private_ip" {
  description = "Private IP of the SSM bastion"
  value       = aws_instance.bastion.private_ip
}

output "ssm_vpc_endpoint_ids" {
  description = "IDs of the SSM interface VPC endpoints (ssm, ssmmessages, ec2messages)"
  value = {
    ssm          = aws_vpc_endpoint.ssm.id
    ssmmessages  = aws_vpc_endpoint.ssmmessages.id
    ec2messages  = aws_vpc_endpoint.ec2messages.id
  }
}

output "subnet_ids" {
  description = "IDs of the public and private subnets"
  value = {
    public_subnet_ids  = [module.subnets_a.public_subnet_id, module.subnets_b.public_subnet_id]
    private_subnet_ids = [module.subnets_a.private_subnet_id, module.subnets_b.private_subnet_id]
  }
}