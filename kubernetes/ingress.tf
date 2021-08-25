resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "ingress-nginx"
  repository = var.ingress_helm_repo
  version    = var.ingress_helm_version

  namespace        = "kube-system"
  create_namespace = false

  dependency_update = true
  atomic            = true

  values = [
    file("configs/nginx-ingress.yaml")
  ]

  set {
    name  = "controller.config.proxy-real-ip-cidr"
    value = var.platform_cidr
  }
}
