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
  name_prefix = "${var.PROJECT_NAME}-${var.ENVIRONMENT_NAME}"
  common_tags = {
    Project     = var.PROJECT_NAME
    Environment = var.ENVIRONMENT_NAME
    Version     = var.VERSION
  }
  vpc_cidr_block      = "192.168.0.0/16"
  subnets             = {
    subnet_a = {
      subnet_cidr  = "192.168.0.0/16"
      public_cidr  = "192.168.0.0/24"
      private_cidr = "192.168.1.0/24"
    }
    subnet_b = {
      subnet_cidr  = "192.168.2.0/16"
      public_cidr  = "192.168.2.0/24"
      private_cidr = "192.168.3.0/24"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

module "subnets_a" {
  source              = "./modules/subnets"
  name_prefix         = local.name_prefix
  tags                = local.common_tags
  vpc_id              = aws_vpc.main.id
  availability_zone   = data.aws_availability_zones.available.names[0]
  igw_id              = aws_internet_gateway.igw.id
  public_subnet_cidr  = local.subnets.subnet_a.public_cidr
  private_subnet_cidr = local.subnets.subnet_a.private_cidr
}


module "subnets_b" {
  source              = "./modules/subnets"
  name_prefix         = local.name_prefix
  tags                = local.common_tags
  vpc_id              = aws_vpc.main.id
  availability_zone   = data.aws_availability_zones.available.names[1]
  igw_id              = aws_internet_gateway.igw.id
  public_subnet_cidr  = local.subnets.subnet_b.public_cidr
  private_subnet_cidr = local.subnets.subnet_b.private_cidr
}


