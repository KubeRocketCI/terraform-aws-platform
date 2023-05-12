region               = "<REGION>"               # e.g. eu-central-1
platform_name        = "<PLATFORM_NAME>"        # e.g. eks-test
platform_domain_name = "<PLATFORM_DOMAIN_NAME>" # e.g. example.com

role_arn             = "<ROLE_ARN>"             # e.g. arn:aws:iam::012345678912:role/EKSDeployerRole
cluster_iam_role_arn = "<CLUSTER_IAM_ROLE_ARN>" # e.g. arn:aws:iam::012345678912:role/AWSServiceRole

vpc_id             = "<VPC_ID>"                                         # e.g. vpc-000
private_subnets_id = ["<PRIVATE_SUBNET_ID_1>", "<PRIVATE_SUBNET_ID_2>"] # eu-central-1a, eu-central-1b. EKS must have two subnets. e.g. subnet-000
public_subnets_id  = ["<PUBLIC_SUBNET_ID_1>", "<PUBLIC_SUBNET_ID_2>"]   # eu-central-1a, eu-central-1b. ALB must have two subnets. e.g. subnet-000

infra_public_security_group_ids = [
  "<INFRASTRUCTURE_PUBLIC_SECURITY_GROUP_ID1>", # e.g. sg-000
  "<INFRASTRUCTURE_PUBLIC_SECURITY_GROUP_ID2>",
]

aws_auth_node_iam_role_arns_non_windows = ["<AWS_AUTH_NODE_IAM_ROLE_ARNS_NON_WINDOWS>"] # e.g. arn:aws:iam::012345678912:role/AmazonEksWorkerNode
worker_iam_instance_profile_arn         = "<WORKER_IAM_INSTANCE_PROFILE_ARN>"           # e.g. arn:aws:iam::012345678912:instance-profile/AmazonEksWorkerNode
role_permissions_boundary_arn           = "<ROLE_PERMISSION_BOUNDARY_ARN>"              # e.g. arn:aws:iam::012345678912:policy/eo_role_boundary

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

// Variables for spot pool
spot_instance_types = [
  { instance_type = "r5.xlarge" },
  { instance_type = "r5.2xlarge" },
  { instance_type = "r5.large" },
  { instance_type = "r4.large" }
]

aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::012345678912:role/EKSClusterAdminRole"
    username = "eksadminrole"
    groups   = ["system:masters"]
  },
]

aws_auth_users = [
  {
    userarn  = "arn:aws:iam::012345678912:user/user_example@example.com"
    username = "user_example@example.com"
    groups   = ["system:masters"]
  }
]

tags = {
  "SysName"      = "<SYS_NAME>"
  "SysOwner"     = "<SYSTEM_OWNER>"
  "Environment"  = "<ENVIRONMENT>"
  "CostCenter"   = "<COST_CENTER>"
  "BusinessUnit" = "<BUSINESS_UNIT>"
  "Department"   = "<DEPARTMENT>"
}

# OIDC Identity provider
#cluster_identity_providers = {
#  keycloak = {
#    client_id    = "eks-examples"
#    issuer_url   = "https://example.com/auth/realms/openshift"
#    groups_claim = "groups"
#  }
#}