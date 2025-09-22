output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.subnets.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.subnets.private_subnet_id
}

output "vpc_cidr" {
  description = "CIDR of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_cidr" {
  description = "CIDR of the public subnet"
  value       = module.subnets.public_subnet_cidr
}

output "private_subnet_cidr" {
  description = "CIDR of the private subnet"
  value       = module.subnets.private_subnet_cidr
}