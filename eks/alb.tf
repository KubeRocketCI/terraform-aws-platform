module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.17.0"

  name = "${var.platform_name}-ingress-alb"

  vpc_id                = var.vpc_id
  subnets               = var.public_subnets_id
  create_security_group = false
  security_groups       = compact(concat(tolist([local.cluster_security_group_id]), var.infra_public_security_group_ids))
  enable_http2          = false

  listeners = {
    http-https-redirect = {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = var.ssl_policy
      certificate_arn = module.acm.acm_certificate_arn

      forward = {
        target_group_key = "http-instance"
      }

      # nginx-ingress -> Envoy Gateway migration: route the configured host header(s)
      # to the Envoy Gateway target group (envoy-instance); every other host keeps
      # hitting the default forward action (http-instance -> nginx-ingress). Enabled
      # per the envoy_gateway_route_enabled flag (default off).
      rules = var.envoy_gateway_route_enabled ? {
        envoy = {
          priority = 10
          actions = [{
            type             = "forward"
            target_group_key = "envoy-instance"
          }]
          conditions = [{
            host_header = {
              values = var.envoy_gateway_route_hosts
            }
          }]
        }
      } : {}
    }
  }

  target_groups = merge(
    {
      http-instance = {
        name                 = "${var.platform_name}-infra-alb-http"
        port                 = 32080
        protocol             = "HTTP"
        deregistration_delay = 20
        create_attachment    = false

        health_check = {
          matcher = 404
        }
      }
    },
    # nginx-ingress -> Envoy Gateway migration: extra target group pointing at the
    # Envoy Gateway data plane NodePort. Added only when the route is enabled, so the
    # default setup is unchanged. No new load balancer is created.
    var.envoy_gateway_route_enabled ? {
      envoy-instance = {
        # Envoy Gateway data plane NodePort (envoy-gateway-resources EnvoyProxy
        # "http-proxy"). ALB terminates TLS on :443 and forwards plain HTTP here.
        name                 = "${var.platform_name}-infra-alb-envoy"
        port                 = 32180
        protocol             = "HTTP"
        deregistration_delay = 20
        create_attachment    = false

        health_check = {
          matcher = "200,404"
        }
      }
    } : {}
  )
  idle_timeout = 500
  access_logs = {
    bucket = "prod-s3-elb-logs-eu-central-1"
  }

  tags = local.tags
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "5.0.0"

  zone_name = var.platform_domain_name
  records = [
    {
      name = "*"
      type = "A"
      alias = {
        name    = module.alb.dns_name
        zone_id = module.alb.zone_id
      }
    }
  ]
}
