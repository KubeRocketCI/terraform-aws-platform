resource "kubernetes_namespace" "security" {
  metadata {
    name = "security"
  }
}

resource "kubernetes_secret" "keycloak_admin" {
  metadata {
    name      = "keycloak-admin-creds"
    namespace = "security"
  }

  data = {
    username = var.keycloak_admin_username
    password = var.keycloak_admin_password
  }

  type = "Opaque"
}

resource "kubernetes_secret" "keycloak_pg_pass" {
  metadata {
    name      = "postgresql"
    namespace = "security"
  }

  data = {
    postgresql-postgres-password = var.keycloak_pg_pass
    postgresql-password          = var.keycloak_pg_pass
  }

  type = "Opaque"
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  chart      = "keycloak"
  repository = var.keycloak_helm_repo
  version    = var.keycloak_helm_version

  namespace        = "security"
  create_namespace = false

  dependency_update = true
  atomic            = true

  values = [
    file("${path.module}/configs/keycloak.yaml")
  ]

  set {
    name  = "ingress.rules[0].host"
    value = "${var.keycloak_name}.${local.dns_wildcard}"
  }

  set {
    name  = "ingress.rules[0].paths[0]"
    value = "/"
  }

  set {
    name  = "image.tag"
    value = var.keycloak_image_tag
  }

  depends_on = [
    kubernetes_secret.keycloak_admin,
    kubernetes_secret.keycloak_pg_pass,
  ]
}
