terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

    backend "s3" {
    bucket         = "terraform-amazon-eks-cluster"
    key            = "helm.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state"
  }
}


provider "aws" {
  region = "us-east-1"
}
