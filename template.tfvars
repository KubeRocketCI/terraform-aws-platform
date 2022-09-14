## Check out all the inputs based on the comments below and fill the gaps instead <...>
## More details on each variable can be found in the variables.tf file

create_elb = true # set to true if you'd like to create ELB for Gerrit usage

region   = "<REGION>"
role_arn = "<ROLE_ARN>"

platform_name        = "<PLATFORM_NAME>"        # the name of the cluster and AWS resources
platform_domain_name = "<PLATFORM_DOMAIN_NAME>" # must be created as a prerequisite

# The following will be created or used existing depending on the create_vpc value
subnet_azs    = ["<SUBNET_AZS1>", "<SUBNET_AZS2>"]
platform_cidr = "<PLATFORM_CIDR>"
private_cidrs = ["<PRIVATE_CIDRS1>", "<PRIVATE_CIDRS2>"]
public_cidrs  = ["<PUBLIC_CIDRS1>", "<PUBLIC_CIDRS2>"]

infrastructure_public_security_group_ids = [
  "<INFRASTRUCTURE_PUBLIC_SECURITY_GROUP_IDS1>",
  "<INFRASTRUCTURE_PUBLIC_SECURITY_GROUP_IDS2>",
]

ssl_policy = "<SSL_POLICY>"

# EKS cluster configuration
cluster_version = "1.20"
key_name        = "<AWS_KEY_PAIR_NAME>" # must be created as a prerequisite
enable_irsa     = true

cluster_iam_role_name            = "<SERVICE_ROLE_FOR_EKS>"
worker_iam_instance_profile_name = "<SERVICE_ROLE_FOR_EKS_WORKER_NODE"

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

map_users = [
  {
    "userarn" : "<IAM_USER_ARN1>",
    "username" : "<IAM_USER_NAME1>",
    "groups" : ["system:masters"]
  },
  {
    "userarn" : "<IAM_USER_ARN2>",
    "username" : "<IAM_USER_NAME2>",
    "groups" : ["system:masters"]
  }
]

map_roles = [
  {
    "rolearn" : "<IAM_ROLE_ARN1>",
    "username" : "<IAM_ROLE_NAME1>",
    "groups" : ["system:masters"]
  },
]

tags = {
  "SysName"      = "<SYS_NAME>"
  "SysOwner"     = "<SYSTEM_OWNER>"
  "Environment"  = "<ENVIRONMENT>"
  "CostCenter"   = "<COST_CENTER>"
  "BusinessUnit" = "<BUSINESS_UNIT>"
  "Department"   = "<DEPARTMENT>"
  "user:tag"     = "<PLATFORM_NAME>"
}

# Variables for demand pool
demand_instance_types      = ["r5.large"]
demand_max_nodes_count     = 0
demand_min_nodes_count     = 0
demand_desired_nodes_count = 0

// Variables for spot pool
spot_instance_types      = ["r5.xlarge", "r5.large", "r4.large"] # need to ensure we use nodes with more memory
spot_max_nodes_count     = 2
spot_desired_nodes_count = 2
spot_min_nodes_count     = 2
