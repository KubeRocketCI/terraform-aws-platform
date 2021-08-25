resource "kubernetes_namespace" "edp" {
  metadata {
    name = "edp"
  }
}

resource "kubernetes_secret" "keycloak_admin_for_edp" {
  metadata {
    name      = "keycloak"
    namespace = "edp"
  }

  data = {
    username = var.keycloak_admin_username
    password = var.keycloak_admin_password
  }

  type = "Opaque"
}

resource "kubernetes_secret" "super_admin_db" {
  metadata {
    name      = "super-admin-db"
    namespace = "edp"
  }

  data = {
    username = var.super_admin_db_username
    password = var.super_admin_db_password
  }

  type = "Opaque"
}

resource "kubernetes_secret" "db_admin_console" {
  metadata {
    name      = "db-admin-console"
    namespace = "edp"
  }

  data = {
    username = var.db_admin_console_username
    password = var.db_admin_console_password
  }

  type = "Opaque"
}

resource "helm_release" "edp" {
  name       = "edp"
  chart      = "edp-install"
  repository = var.edp_helm_repo
  version    = var.edp_helm_version

  namespace        = "edp"
  create_namespace = false

  dependency_update = true
  atomic            = true

  values = [
    templatefile("${path.module}/configs/edp.yaml.tmpl", {
      dns_wildcard        = local.dns_wildcard
      web_console_url     = var.web_console_url
      admins              = var.admins
      developers          = var.developers
      keycloak_url        = "https://${var.keycloak_name}.${local.dns_wildcard}"
      docker_registry_url = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"
      kaniko_role_arn     = var.kaniko_role_arn
    })
  ]

  depends_on = [
    kubernetes_secret.keycloak_admin_for_edp,
    kubernetes_secret.super_admin_db,
    kubernetes_secret.db_admin_console,
    helm_release.keycloak,
    helm_release.kiosk,
    helm_release.ingress,
  ]
}
