terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.0"

  name = "infinity-labs-vpc"
  cidr = var.vpc_cidr

  # create 2 az for ha
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # nat gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true # in prod i will use more than 1 nat
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  #tags for alb for sevice lb in eks
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  # enable flow logs to track network traffic (cloudwatch) - for sec
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
}