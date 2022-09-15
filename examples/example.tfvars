create_vpc     = true # set to true if you'd like to create a new VPC or false if use existing
create_cluster = true # set to false if there are any additional manual steps required between VPC and EKS cluster deployment
create_elb     = true # set to true if you'd like to create ELB for Gerrit usage

region      = "eu-central-1"
aws_profile = "aws_user"
role_arn    = "arn:aws:iam::012345678910:role/EKSDeployerRole"

platform_name        = "test-eks"
platform_domain_name = "example.com" # must be created as a prerequisite
wait_for_validation  = false         # set to false for use in an automated pipeline to avoid waiting for validation to complete or error after a 45 minute timeout.

# The following will be created or used existing depending on the create_vpc value
subnet_azs    = ["eu-central-1a", "eu-central-1b"]
platform_cidr = "172.31.0.0/16"
private_cidrs = ["172.31.0.0/20", "172.31.16.0/20"]
public_cidrs  = ["172.31.32.0/20", "172.31.48.0/20"]

# Define the following only if you're going to use existing VPC and create_vpc is set to false
vpc_id             = "vpc-00000000000000000"
private_subnets_id = ["subnet-00000000000000001", "subnet-00000000000000002"] # eu-central-1a, eu-central-1b
public_subnets_id  = ["subnet-00000000000000003", "subnet-00000000000000004"] # eu-central-1a, eu-central-1b
nat_public_cidrs   = ["10.11.12.13/32"]

# Define CIDR blocks and/or prefix lists if any to whitelist for public access on LBs. Use short description
ingress_cidr_blocks     = ["192.168.64.0/24"]
ingress_prefix_list_ids = []

# Define existing security groups ids if any in order to whitelist for public access on LBs. Makes sense with create_vpc = false only.
public_security_group_ids = []

# EKS cluster configuration
cluster_version = "1.22"
key_name        = "test-kn" # must be created as a prerequisite
enable_irsa     = true

# Define if IAM roles should be created during the deployment or used existing ones
manage_cluster_iam_resources     = false # if set to false, cluster_iam_role_name must be specified
manage_worker_iam_resources      = false # if set to false, worker_iam_instance_profile_name must be specified for workers
cluster_iam_role_name            = "ServiceRoleForEKSSharedCluster"
worker_iam_instance_profile_name = "ServiceRoleForEksSharedWorkerNode"

# Uncomment if your AWS CLI version is 1.16.156 or later
kubeconfig_aws_authenticator_command = "aws"

# Environment varibles to put into kubeconfig file to use when executing the authentication, such as AWS profile of IAM user for authentication
kubeconfig_aws_authenticator_env_variables = {
  AWS_PROFILE = "aws_user"
}

add_userdata = <<EOF
export TOKEN=$(aws ssm get-parameter --name param_name --query 'Parameter.Value' --region eu-central-1 --output text)
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
    "userarn" : "arn:aws:iam::012345678910:user/user_name1@example.com",
    "username" : "user_name1@example.com",
    "groups" : ["system:masters"]
  },
  {
    "userarn" : "arn:aws:iam::012345678910:user/user_name2@example.com",
    "username" : "user_name2@example.com",
    "groups" : ["system:masters"]
  }
]

map_roles = [
  {
    "rolearn" : "arn:aws:iam::012345678910:role/EKSClusterAdminRole",
    "username" : "eksadminrole",
    "groups" : ["system:masters"]
  },
]

tags = {
  "SysName"      = "EKS"
  "SysOwner"     = "owner@example.com"
  "Environment"  = "EKS-TEST-CLUSTER"
  "CostCenter"   = "2020"
  "BusinessUnit" = "BU"
  "Department"   = "DEPARTMENT"
  "user:tag"     = "test-eks"
}

demand_instance_types = ["r5.large"]
spot_instance_types   = ["r5.large", "r4.large"] # need to ensure we use nodes with more memory

# Multitenancy processing
tenants = {
  # use default values to create worker group with spot instance types
  "0" = {},

  # define all possible inputs for custom tenant configuration
  "1" = {
    name                     = "tenant2-name"
    create_iam_kaniko        = true
    create_iam_worker_group  = true
    namespace                = "tenant2-namespace"
    attach_worker_cni_policy = false
    attach_worker_efs_policy = false

    instance_type                            = "on-demand"
    override_instance_types                  = ["r4.large"]
    on_demand_percentage_above_base_capacity = 100
    spot_instance_pools                      = 2
    asg_min_size                             = 3
    asg_max_size                             = 4
    asg_desired_capacity                     = 4
    subnets                                  = ["subnet-00000000000000001"]
    kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=normal --node-labels=project=tenant2-name"
    suspended_processes                      = ["ReplaceUnhealthy"]
    root_volume_size                         = 40
    enable_monitoring                        = true
    key_name                                 = "key-name"
    iam_instance_profile_name                = "ServiceRoleForEksSharedWorkerNode"

    tags = [
      {
        "key"                 = "user:tag"
        "propagate_at_launch" = "true"
        "value"               = "tenant2-name"
      }
    ]

  },
  # mix default and custom values for inputs
  "2" = {
    name                     = "tenant-awesome-name"
    create_iam_worker_group  = true
    attach_worker_efs_policy = false
    instance_type            = "spot"
    spot_instance_pools      = 5
    asg_min_size             = 1 # must be less or equal to desired_nodes_count
    asg_max_size             = 3
    asg_desired_capacity     = 2
    suspended_processes      = ["AZRebalance", "ReplaceUnhealthy"]
    enable_monitoring        = true

    tags = [
      {
        "key"                 = "custom:tag"
        "propagate_at_launch" = "true"
        "value"               = "tenant3-name"
      }
    ]
  }
}
