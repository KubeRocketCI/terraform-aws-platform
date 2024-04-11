## EKS Module Upgrade Guide

This guide outlines the steps to upgrade the EKS module in your Terraform configuration to a newer version.
Follow these steps sequentially for a smooth upgrade process.

### Prerequisites

Ensure you have the latest version of Terraform installed and your AWS credentials configured properly.

### Update to Version 19.21.0

First, update your EKS module to version 19.21.0 in your Terraform configuration.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"
}
```

Steps:

1. Apply the Terraform changes.

    ```bash
    terraform init -upgrade
    terraform apply
    ```

2. Commit the changes to your version control system.

    ```bash
    git commit -m "chore: Bump eks module from 19.16.0 to 19.21.0"
    ```

### Migrate to Custom 20.x EKS Module

To migrate to the custom 20.x EKS module, follow the instructions provided in the [migration guide](https://github.com/clowdhaus/terraform-aws-eks-migrate-v19-to-v20).

```hcl
module "eks" {
  source  = "git@github.com:clowdhaus/terraform-aws-eks-v20-migrate.git?ref=3f626cc493606881f38684fc366688c36571c5c5"
}
```

Steps:

1. Apply the Terraform changes.

    ```bash
    terraform init -upgrade
    terraform apply
    ```



2. If you encounter an error stating that the cluster does not have API configuration, run terraform apply again.

3. Apply the Terraform changes once more.

    ```bash
    terraform apply
    ```

4. Commit the changes to your version control system.

   ```bash
   git commit -m "chore: Migrate to custom 20.x eks module"
   ```

### Update to Version 20.8.5

Finally, update the EKS module to version 20.8.5.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"
}
```

Steps:

1. Upgrade the Terraform initialization.

   ```bash
   terraform init -upgrade
   ```

2. Remove the following lines from your Terraform configuration.

   ```hcl
   create_aws_auth_configmap = true
   manage_aws_auth_configmap = true

   aws_auth_users = var.aws_auth_users
   aws_auth_roles = var.aws_auth_roles
   ```

3. Remove the old aws-auth config map from the Terraform state.

   ```bash
   terraform state rm 'module.eks.kubernetes_config_map_v1_data.aws_auth[0]'
   terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]'
   ```

4. Add the aws-auth module with the updated configuration.

   ```hcl
   module "eks_aws_auth" {
     source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
     version = "20.8.4"

     create_aws_auth_configmap = true
     manage_aws_auth_configmap = true

     aws_auth_roles = var.aws_auth_roles
     aws_auth_users = var.aws_auth_users
   }
   ```

5. Upgrade the Terraform initialization again.

   ```bash
   terraform init -upgrade
   ```

6. Import the aws-auth config map into the Terraform state.

   ```bash
   terraform import 'module.eks_aws_auth.kubernetes_config_map.aws_auth[0]' kube-system/aws-auth
   ```

7. Apply the Terraform changes.

   ```bash
   terraform apply
    ```

8. Commit the final changes to your version control system.

    ```bash
    git commit -m "chore: Migrate to the 20.x version of eks module"
    ```

Follow these steps carefully to ensure a successful upgrade of your EKS module.
