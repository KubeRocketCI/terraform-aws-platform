locals {
  target_groups = [
    {
      "name"                 = "${var.platform_name}-infra-alb-http"
      "backend_port"         = "32080"
      "backend_protocol"     = "HTTP"
      "deregistration_delay" = "20"
      "health_check_matcher" = "404" # ingress default-backend response code
    },
    {
      "name"                 = "${var.platform_name}-infra-alb-https"
      "backend_port"         = "32443"
      "backend_protocol"     = "HTTPS"
      "deregistration_delay" = "20"
      "health_check_matcher" = "404" # ingress default-backend response code
    },
  ]

  default_security_group_id = data.aws_security_group.default.id
}
