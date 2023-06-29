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

output "my_oidc_provider_url" {
  value = aws_iam_openid_connect_provider.my_oidc_provider.arn
}

output "my_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.my_oidc_provider.arn
}

output "frontend_role_iam" {
  value = aws_iam_role.frontend_role.arn
}

output "backend_role_iam" {
  value = aws_iam_role.backend_role.arn
}
