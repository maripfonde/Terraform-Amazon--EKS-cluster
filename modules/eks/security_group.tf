resource "aws_security_group" "eks_node_group_sg" {
  name        = "eks-node-group-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow nodes to communicate with each other"

    from_port = 0
    to_port   = 65535
    protocol  = -1
  }

  ingress {
    from_port = 1025
    to_port   = 65535
    protocol  = "tcp"
  }

  ingress {
  from_port = 9443
  to_port   = 9443
  protocol  = "tcp"
}

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
  }

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}
