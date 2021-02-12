provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = [var.vpc_azs]
  public_subnets  = [var.vpc_public_subnet]
  # uncomment to add a private subnet
  # private_subnets = ["${var.vpc_private_subnet}"]

  # assign_generated_ipv6_cidr_block = true

  # uncomment if you need private subnet to access internet
  # enable_nat_gateway = true
  # single_nat_gateway = true
  
  public_subnet_tags = {
    Name = var.vpc_public_subnet_name
  }

  # uncomment if you added a private subnet
  # private_subnet_tags = {
  #   Name = "${var.vpc_private_subnet_name}"
  # }

  tags = {
    Owner       = var.tag1
    Environment = var.tag2
  }

  vpc_tags = {
    Name = var.tag3
  }
}
