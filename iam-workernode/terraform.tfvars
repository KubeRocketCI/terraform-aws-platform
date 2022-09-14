# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>
# More details on each variable can be found in the variables.tf file

region = "<REGION>" # mandatory

platform_name = "<PLATFORM_NAME>" # mandatory

role_arn = "<ROLE_ARN" # role to assume to run terraform apply, isn't mandatory

iam_permissions_boundary_policy_arn = "<AWS_PERMISSIONS_BOUNDARY_ARN>" # mandatory

tags = "<TAGS>" # isn't mandatory
