resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

#iam for worker node
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

#frontend-role
resource "aws_iam_role" "frontend_role" {
  name = "frontend-role"

  assume_role_policy = templatefile("${path.module}/../policies/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.my_oidc_provider.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.my_oidc_provider.url, "https://", ""), NAMESPACE = "${var.namespace}", SA_NAME = "frontend-service-account" })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.frontend_role.name
}

#backend-role
resource "aws_iam_role" "backend_role" {
  name = "backend-role"

  assume_role_policy = templatefile("${path.module}/../policies/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.my_oidc_provider.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.my_oidc_provider.url, "https://", ""), NAMESPACE = "${var.namespace}", SA_NAME = "backend-service-account" })
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.backend_role.name
}


#lb controller role
resource "aws_iam_policy" "lb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  policy      = "${file("${path.module}/../policies/iam_policy.json")}"
}

resource "aws_iam_role" "lb_controller" {
  name = "aws-load-balancer-controller-role"

  assume_role_policy = templatefile("${path.module}/../policies/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.my_oidc_provider.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.my_oidc_provider.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "aws-load-balancer-controller" })
}

resource "aws_iam_role_policy_attachment" "lb_policy_attachment" {
  policy_arn  = aws_iam_policy.lb_policy.arn
  role        = aws_iam_role.lb_controller.name
}

#vpc cni
resource "aws_iam_role" "vpc_cni" {
  name               = "vpc-cni-role"
  assume_role_policy = templatefile("${path.module}/../policies/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.my_oidc_provider.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.my_oidc_provider.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "aws-node" })
}

resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni.name
}

#external dns
resource "aws_iam_policy" "dns_policy" {
  name        = "ExternalDNSIAMPolicy"
  policy      = "${file("${path.module}/../policies/external-dns-policy.json")}"
}

resource "aws_iam_role" "external_dns" {
  name = "external-dns-role"

  assume_role_policy = templatefile("${path.module}/../policies/oidc_assume_role_policy.json", { OIDC_ARN = aws_iam_openid_connect_provider.my_oidc_provider.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.my_oidc_provider.url, "https://", ""), NAMESPACE = "default", SA_NAME = "external-dns" })
}

resource "aws_iam_role_policy_attachment" "dns_policy_attachment" {
  policy_arn  = aws_iam_policy.dns_policy.arn
  role        = aws_iam_role.external_dns.name
}
