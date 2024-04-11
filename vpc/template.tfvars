# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>
# More details on each variable can be found in the variables.tf file

# -- e.g eu-central-1
region = "<REGION>"

role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/EKSDeployerRole"

platform_name = "<PLATFORM_NAME>"

# -- VPC CIDR, e.g. "10.0.0.0/16"
platform_cidr = "<PLATFORM_CIDR>"

# -- VPC Subnets AZs, e.g. ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
subnet_azs = ["<SUBNET_AZS1>", "<SUBNET_AZS2>"]

# -- Private Subnets CIDR, e.g. ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_cidrs = ["<PRIVATE_CIDRS1>", "<PRIVATE_CIDRS2>"]

# -- Private Subnets CIDR, e.g. ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
public_cidrs = ["<PUBLIC_CIDRS1>", "<PUBLIC_CIDRS2>"]

# -- Tags for resources, isn't mandatory
tags = ""
