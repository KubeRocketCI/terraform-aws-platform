resource "aws_lb_ssl_negotiation_policy" "this" {
  count = var.create_elb && var.create_cluster ? 1 : 0

  name          = "${var.platform_name}-ELBSecurityPolicy-TLS-1-2-2017-01"
  load_balancer = module.elb.elb_name
  lb_port       = 443

  # Protocol preferences
  attribute {
    name  = "Protocol-TLSv1.2"
    value = "true"
  }

  attribute {
    name  = "Server-Defined-Cipher-Order"
    value = "true"
  }

  # Cipher preferences
  attribute {
    name  = "ECDHE-ECDSA-AES128-GCM-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-ECDSA-AES128-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-ECDSA-AES256-GCM-SHA384"
    value = "true"
  }
  attribute {
    name  = "ECDHE-ECDSA-AES256-SHA384"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES128-GCM-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES128-SHA256"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES256-GCM-SHA384"
    value = "true"
  }
  attribute {
    name  = "ECDHE-RSA-AES256-SHA384"
    value = "true"
  }
  attribute {
    name  = "AES128-GCM-SHA256"
    value = "true"
  }
  attribute {
    name  = "AES128-SHA256"
    value = "true"
  }
  attribute {
    name  = "AES256-GCM-SHA384"
    value = "true"
  }
  attribute {
    name  = "AES256-SHA256"
    value = "true"
  }
}
