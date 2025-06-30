region               = "<REGION>"
platform_name        = "<PLATFORM_NAME>"
platform_domain_name = "<PLATFORM_DNS>"

role_arn                      = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/KRCIDeployerRole"
role_permissions_boundary_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:policy/eo_role_boundary"

create_kaniko_iam_role   = false # Create IAM role for Kaniko
create_atlantis_iam_role = false # Create IAM role for Atlantis

create_cd_pipeline_operator_irsa = false # Create IRSA for CD Pipeline Operator
create_argocd_irsa               = false # Create IRSA for Argo CD

cd_pipeline_operator_agent_role_arn = "arn:aws:iam::<AWS_ACCOUNT_B_ID>:role/AWSIRSA_<ClusterName>_CDPipelineAgent"
argocd_agent_role_arn               = "arn:aws:iam::<AWS_ACCOUNT_B_ID>:role/AWSIRSA_<ClusterName>_ArgoCDAgentAccess"
# cd_pipeline_operator_irsa_role_arn  = "arn:aws:iam::<AWS_ACCOUNT_A_ID>:role/AWSIRSA_<ClusterName>_CDPipelineOperator"
# argocd_irsa_role_arn                = "arn:aws:iam::<AWS_ACCOUNT_A_ID>:role/AWSIRSA_<ClusterName>_ArgoCDMaster"

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
