

data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

data "aws_elb_hosted_zone_id" "this" {}

resource "aws_route53_record" "ingress" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id

  name = "www.${var.domain_name}"
  type = "A"

  alias {
    evaluate_target_health = true
    name                   = kubernetes_service_v1.ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.this.id
  }
}

resource "aws_route53_record" "ingress2" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id

  name = var.domain_name
  type = "A"

  alias {
    evaluate_target_health = true
    name                   = kubernetes_service_v1.ingress.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.this.id
  }
}


resource "kubernetes_service_v1" "ingress" {
  metadata {
    name = "ingress"
    annotations = {
      "external-dns.alpha.kubernetes.io/hostname" = var.domain_name
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = aws_acm_certificate.main.arn
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "https"
    }
  }

  spec {
    selector = {
      app = "myapp"
    }

    type = "LoadBalancer"

    port {
      name       = "http"
      port       = 80
      target_port = 80
    }

    port {
      name       = "https"
      port       = 443
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name = "frontend-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
    }
  }
  spec {
    rule {
      host = var.domain_name
      http {
        path {
          path = "/*"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.ingress.metadata.0.name
              port {
                number   = 443
              }
            }
          }
        }
      }
    }
     tls {
      hosts = [var.domain_name]
    }
  }
}
