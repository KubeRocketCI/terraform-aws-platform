# Check out all the inputs based on the comments below and fill the gaps instead <...>
# More details on each variable can be found in the variables.tf file

create_vpc     = true # set to true if you'd like to create a new VPC or false if use existing
create_cluster = true # set to false if there are any additional manual steps required between VPC and EKS cluster deployment
create_elb     = true # set to true if you'd like to create ELB for Gerrit usage

region      = "<REGION>"
aws_profile = "<AWS_PROFILE>"
role_arn    = "<ROLE_ARN>"

platform_name        = "<PLATFORM_NAME>"        # the name of the cluster and AWS resources
platform_domain_name = "<PLATFORM_DOMAIN_NAME>" # must be created as a prerequisite
wait_for_validation  = true                     # set to false for use in an automated pipeline to avoid waiting for validation to complete or error after a 45 minute timeout.

# The following will be created or used existing depending on the create_vpc value
subnet_azs    = ["<SUBNET_AZS1>", "<SUBNET_AZS2>"]
platform_cidr = "<PLATFORM_CIDR>"
private_cidrs = ["<PRIVATE_CIDRS1>", "<PRIVATE_CIDRS2>"]
public_cidrs  = ["<PUBLIC_CIDRS1>", "<PUBLIC_CIDRS2>"]

# Define the following only if you're going to use existing VPC and create_vpc is set to false
vpc_id             = "<VPC_ID>"
private_subnets_id = ["<PRIVATE_SUBNETS_ID1>", "<PRIVATE_SUBNETS_ID2>"] # "<SUBNET_AZS1>", "<SUBNET_AZS2>"
public_subnets_id  = ["<PUBLIC_SUBNETS_ID1>", "<PUBLIC_SUBNETS_ID2>"]   # "<SUBNET_AZS1>", "<SUBNET_AZS2>"
nat_public_cidrs   = ["<NAT_PUBLIC_CIDRS>"]

# Define CIDR blocks and/or prefix lists if any to whitelist for public access on LBs
ingress_cidr_blocks = ["<PUBLIC_CIDR>"]
ingress_prefix_list_ids = [
  {
    description      = "<SHORT_DESCRIPTION1"
    public_prefix_id = "<PREFIX_LIST_ID1>"
  },
  {
    description      = "<SHORT_DESCRIPTION2"
    public_prefix_id = "<PREFIX_LIST_ID2>"
  },
]

# Define existing security groups ids if any in order to whitelist for public access on LBs. Makes sense with create_vpc = false only.
public_security_group_ids = [
  "<PUBLIC_SECURITY_GROUP_IDS1>",
  "<PUBLIC_SECURITY_GROUP_IDS2>",
]

# EKS cluster configuration
cluster_version = "1.18"
key_name        = "<AWS_KEY_PAIR_NAME>" # must be created as a prerequisite
enable_irsa     = true

# Define if IAM roles should be created during the deployment or used existing ones
manage_cluster_iam_resources     = false # if set to false, cluster_iam_role_name must be specified
manage_worker_iam_resources      = false # if set to false, worker_iam_instance_profile_name must be specified for workers
cluster_iam_role_name            = "<SERVICE_ROLE_FOR_EKS>"
worker_iam_instance_profile_name = "<SERVICE_ROLE_FOR_EKS_WORKER_NODE"

# Uncomment if your AWS CLI version is 1.16.156 or later
kubeconfig_aws_authenticator_command = "aws"

# Environment varibles to put into kubeconfig file to use when executing the authentication, such as AWS profile of IAM user for authentication
kubeconfig_aws_authenticator_env_variables = {
  AWS_PROFILE = "<AWS_PROFILE>"
}

add_userdata = <<EOF
export TOKEN=$(aws ssm get-parameter --name edprobot --query 'Parameter.Value' --region <REGION> --output text)
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

demand_instance_types = ["r5.large"]
spot_instance_types   = ["r5.large", "r4.large"] # need to ensure we use nodes with more memory
