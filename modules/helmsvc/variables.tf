variable "env_code" {
  default = "prod"
}

variable "region" {
  default = "us-east-1"
}

locals {
  cluster_name = "eks-cluster"
}

variable "cluster_name" {
  default = "eks-cluster"
}

variable "cluster_endpoint" {}

variable "token" {}

variable "certificate_authority" {}

variable "domain_name" {
  default = "lawrencecloudlab.com"
  type    = string
}

variable "record_name" {
  default = "www"
  type    = string
}
