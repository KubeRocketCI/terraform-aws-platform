region               = "eu-central-1"
platform_name        = "eks-test"
platform_domain_name = "example.com"

role_arn                      = "arn:aws:iam::012345678910:role/KRCIDeployerRole"
role_permissions_boundary_arn = "arn:aws:iam::012345678910:policy/eo_role_boundary"

# -- Scope of the IAM roles for ServiceAccounts; see eks/variables.tf.
external_secrets_service_accounts     = ["krci:externalsecrets-aws"]
external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:eu-central-1:012345678910:secret:/edp/*"]
external_secrets_kms_key_arns         = []
kaniko_service_accounts               = ["krci:tekton"]
kaniko_repository_actions = [
  "ecr:BatchCheckLayerAvailability",
  "ecr:BatchGetImage",
  "ecr:CompleteLayerUpload",
  "ecr:GetDownloadUrlForLayer",
  "ecr:InitiateLayerUpload",
  "ecr:PutImage",
  "ecr:UploadLayerPart",
]

vpc_id             = "vpc-053a2853a6b2649da"
private_subnets_id = ["subnet-012345678910", "subnet-012345678910"] # eu-central-1a, eu-central-1b. EKS must have two subnets.
public_subnets_id  = ["subnet-012345678910", "subnet-012345678910"] # eu-central-1a, eu-central-1b. ALB must have two subnets.

infra_public_security_group_ids = [
  "sg-012345678910",
  "sg-012345678910",
]


# -- Parameter in AWS Parameter Store that contain data in format "account:token" in base64 format
add_userdata = <<-EOF
#!/bin/bash
export TOKEN=$(aws ssm get-parameter --name edpdockeraccount --query 'Parameter.Value' --region eu-central-1 --output text)
cat <<DATA > /var/lib/kubelet/config.json
{
  "auths":{
    "https://index.docker.io/v1/":{
      "auth":"$TOKEN"
    }
  }
}
DATA
EOF

spot_instance_types = [
  { instance_type = "r5.xlarge" },
  { instance_type = "r5.2xlarge" }
]

tags = {
  "SysName"      = "KubeRocketCI"
  "Environment"  = "EKS-TEST-CLUSTER"
  "CostCenter"   = "2023"
  "BusinessUnit" = "EDP"
}

# OIDC Identity provider
cluster_identity_providers = {
  keycloak = {
    client_id    = "kubernetes"
    issuer_url   = "https://keycloak.com/auth/realms/openshift"
    groups_claim = "groups"
  }
}

# -- nginx-ingress -> Envoy Gateway migration (optional, default off) ----------
# Two related switches for a zero-downtime cutover; see eks/variables.tf.
# Step 1 - provision the Envoy Gateway data-plane target group (no traffic yet):
# envoy_gateway_enabled = true
# Step 2 - once that target group is healthy, flip the ALB default action to Envoy:
# platform_default_gateway = "envoy"
