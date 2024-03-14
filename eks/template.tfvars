region               = "<REGION>"
platform_name        = "<PLATFORM_NAME>"
platform_domain_name = "<PLATFORM_DNS>"

role_arn                      = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/EKSDeployerRole"
role_permissions_boundary_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/eo_role_boundary"

vpc_id             = "<VPC_ID>" # VPC ID
private_subnets_id = []         # EKS must have two subnets.
public_subnets_id  = []         # ALB must have two subnets.

infra_public_security_group_ids = [] # List with security groups

# -- Parameter in AWS Parameter Store that contain data in format "account:token" in base64 format
add_userdata = <<EOF
export TOKEN=$(aws ssm get-parameter --name <PARAMETER_NAME> --query 'Parameter.Value' --region <REGION> --output text)
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

spot_instance_types = [] # list with instance types

aws_auth_users = [] # -- AWS List users
tags           = ""

# OIDC Identity provider
cluster_identity_providers = {}
