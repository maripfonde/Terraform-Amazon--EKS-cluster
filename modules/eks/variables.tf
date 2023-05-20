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
