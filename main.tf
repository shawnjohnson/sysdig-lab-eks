terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.39"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 1.0.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_region" "current" {}

output "region" {
    value = data.aws_region.current
}

data "aws_security_groups" "vpc" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
}