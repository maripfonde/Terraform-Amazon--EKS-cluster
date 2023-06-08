output "aws_security_group" {
  value = aws_security_group.eks_node_group_sg.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.eks_cluster.name
}

output "token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}
