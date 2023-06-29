variable "env_code" {}

variable "subnet_ids" {}

variable "vpc_id" {}

variable "node_group_name" {
  type    = string
  default = "eks-node-group-1"
}

locals {
  cluster_name = "eks-cluster"
}

variable "region" {
  default = "us-east-1"
}

variable "namespace" {
  default = "default"
}

variable "oidc_thumbprint_list" {
  type    = list(string)
  default = []
}

variable "service_account" {
  default = "frontend-service-account"
}

variable "account_id" {
  default = "387738881290"
}
