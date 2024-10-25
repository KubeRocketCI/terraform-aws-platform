# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>
# More details on each variable can be found in the variables.tf file

region = "eu-central-1"

role_arn = "arn:aws:iam::0123456789:role/KRCIDeployerRole"

platform_name = "eks-test"

platform_cidr = "10.0.0.0/16"

subnet_azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

private_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

public_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

tags = {
  "SysName"     = "KubeRocketCI"
  "Environment" = "EKS-TEST-CLUSTER"
  "Project"     = "EDP"
}
