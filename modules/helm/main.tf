provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.certificate_authority
    token                  = var.token
  }
}


resource "helm_release" "game-2048" {
  name      = "2048"
  namespace = "default"
  chart     = "${path.module}/helm/game-2048"
  values    =  [file("${path.module}/helm/game-2048/values.yaml")]
}
