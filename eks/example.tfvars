region               = "eu-central-1"
platform_name        = "eks-test"
platform_domain_name = "example.com"

role_arn                      = "arn:aws:iam::012345678910:role/EKSDeployerRole"
role_permissions_boundary_arn = "arn:aws:iam::012345678910:policy/eo_role_boundary"

vpc_id             = "vpc-053a2853a6b2649da"
private_subnets_id = ["subnet-012345678910", "subnet-012345678910"] # eu-central-1a, eu-central-1b. EKS must have two subnets.
public_subnets_id  = ["subnet-012345678910", "subnet-012345678910"] # eu-central-1a, eu-central-1b. ALB must have two subnets.

infra_public_security_group_ids = [
  "sg-012345678910",
  "sg-012345678910",
]


# -- Parameter in AWS Parameter Store that contain data in format "account:token" in base64 format
add_userdata = <<EOF
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

aws_auth_users = [
  {
    userarn  = "arn:aws:iam::012345678910:user/user1@example.com"
    username = "user1@example.com"
    groups   = ["system:masters"]
  },
  {
    userarn  = "arn:aws:iam::012345678910:user/user2@example.com"
    username = "user2@example.com"
    groups   = ["system:masters"]
  }
]
tags = {
  "SysName"      = "EPAM"
  "Environment"  = "EKS-TEST-CLUSTER"
  "CostCenter"   = "2023"
  "BusinessUnit" = "EDP"
}

enable_argocd = true

argocd_manage_add_ons = true

eks_addons_repo_ssh_key_secret_name = "ssh-key"

repo_url = "git@github.com:epam/edp-cluster-add-ons.git"

addons_path = "chart"

# OIDC Identity provider
cluster_identity_providers = {
  keycloak = {
    client_id    = "kubernetes"
    issuer_url   = "https://keycloak.com/auth/realms/openshift"
    groups_claim = "groups"
  }
}
