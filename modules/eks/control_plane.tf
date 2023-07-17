resource "aws_eks_cluster" "eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids             = var.subnet_ids
    endpoint_public_access = true
    public_access_cidrs    = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_service_policy_attachment
  ]

  tags = {
    "Name" = var.env_code
  }

}

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "my_oidc_provider" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = concat([data.tls_certificate.cluster.certificates.0.sha1_fingerprint], var.oidc_thumbprint_list)  
}

resource "aws_eks_identity_provider_config" "example" {
  cluster_name = aws_eks_cluster.eks_cluster.name

  oidc {
    client_id                     = "${substr(aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer, -32, -1)}"
    identity_provider_config_name = "eks-cluster"
    issuer_url                    = "https://${aws_iam_openid_connect_provider.my_oidc_provider.url}"
  }
}

# Enable the AWS VPC CNI addon
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = local.cluster_name
  addon_name   = "vpc-cni"


  service_account_role_arn = aws_iam_role.vpc_cni.arn

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
