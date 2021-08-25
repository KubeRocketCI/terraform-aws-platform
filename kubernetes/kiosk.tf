resource "helm_release" "kiosk" {
  name       = "kiosk"
  chart      = "kiosk"
  repository = var.kiosk_helm_repo
  version    = var.kiosk_helm_version

  namespace        = "kiosk"
  create_namespace = true

  dependency_update = true
  atomic            = true
}
