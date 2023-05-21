terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

    backend "s3" {
    bucket         = "terraform-amazon-eks-cluster"
    key            = "dev.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state"
  }
}

provider "aws" {
  region = var.region
}

module base {
  source = "../../modules/base"

  env_code     = var.env_code
  vpc_cidr     = var.vpc_cidr
  private_cidr = var.private_cidr
  public_cidr  = var.public_cidr
}
