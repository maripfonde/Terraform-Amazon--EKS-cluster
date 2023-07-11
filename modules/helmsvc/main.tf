provider "kubernetes" {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.certificate_authority
    token                  = var.token
    
}


provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.certificate_authority
    token                  = var.token
  }
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::387738881290:role/aws-load-balancer-controller-role"
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart     = "aws-load-balancer-controller"
  version   = "1.5.4"

   set {
    name  = "clusterName"
    value = "eks-cluster"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller.metadata.0.name
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  depends_on = [ kubernetes_service_account.aws_load_balancer_controller ]
}



resource "kubernetes_service_account" "external_dns_service_account" {
  metadata {
    name      = "external-dns"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::387738881290:role/external-dns-role"
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  namespace = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "external-dns"
  version   = "6.20.4"

  set {
    name  = "aws.region"
    value = "us-east-1"
  }

  set {
    name  = "txt-owner-id"
    value = "www.lawrencecloudlab.com"
  }

  set {
    name  = "txt-prefix"
    value = "external-dns"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.external_dns_service_account.metadata.0.name
  }

  set {
    name  = "provider"
    value = "aws"
  }
}

resource "helm_release" "game-2048" {
  name      = "2048"
  namespace = "default"
  chart     = "${path.module}/helm/game-2048"
  values    = [file("${path.module}/helm/game-2048/values.yaml")]

  set {
    name  = "ingress.hostname"
    value = "www.lawrencecloudlab.com"
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.annotations.kubernetes.io/ingress.class"
    value = "alb"
  }

  set {
    name  = "ingress.annotations.alb.ingress.kubernetes.io/target-type"
    value = "ip"
  }

  depends_on = [ helm_release.aws_load_balancer_controller, helm_release.external_dns ]
}
