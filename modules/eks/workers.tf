resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = local.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.ecr_readonly_policy_attachment,
    aws_iam_role_policy_attachment.cloudwatch_agent_policy_attachment,
    aws_eks_cluster.eks_cluster
  ]

  tags = {
    "Name" = var.env_code
  }
}
