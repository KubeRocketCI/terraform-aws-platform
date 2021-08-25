# Template file to use as an example to create terraform.tfvars file. Fill the gaps instead of <...>

# Define the following with corresponding values from the EKS cluster deployment input variables
aws_account_id       = "<AWS_ACCOUNT_ID>"
region               = "<REGION>"
platform_name        = "<PLATFORM_NAME>"
platform_domain_name = "<PLATFORM_DOMAIN_NAME>"
platform_cidr        = "<PLATFORM_CIDR>"

# Define the exact helm charts versions to install. If there are not specified, the latest versions are installed.
edp_helm_version = "2.8.0"
edp_helm_repo    = "https://chartmuseum.demo.edp-epam.com/"
web_console_url  = "https://01AA58303FB7A71A975DC9FDA2343262.gr7.eu-central-1.eks.amazonaws.com"
admins           = ["<USER1>", "<USER2>"]
developers       = ["<USER1>", "<USER2>"]
kaniko_role_arn  = "<KANIKO_ROLE_ARN>"

ingress_helm_version = "3.23.0"
ingress_helm_repo    = "https://kubernetes.github.io/ingress-nginx"

keycloak_helm_version = "11.0.1"
keycloak_helm_repo    = "https://codecentric.github.io/helm-charts"
keycloak_image_tag    = "13.0.1"

kiosk_helm_version = "0.2.9"
kiosk_helm_repo    = "https://charts.devspace.sh/"
