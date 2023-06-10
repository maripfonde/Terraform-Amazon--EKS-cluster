provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}


resource "helm_release" "game-2048" {
  name      = "2048"
  namespace = "default"
  chart     = "${path.module}/helm/game-2048"
  values    =  [file("${path.module}/helm/game-2048/values.yaml")]
}
