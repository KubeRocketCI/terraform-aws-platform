# Deploy EKS Cluster using Terraform

This project is primarily focused on creating and managing AWS EKS cluster and AWS resources like VPCs, EKS clusters, IAM roles, and S3 buckets using Terraform scripts. The repository consists of various components:

`.pre-commit-config.yaml`: This file is used to configure pre-commit hooks. Pre-commit hooks are scripts that run automatically every time you make a commit. They are used to enforce certain code standards and prevent bad commits.

`argo-cd/`: This directory contains the Terraform scripts for creating and managing internal and external AWS IAM Roles for Argo CD.

`docs/`: This directory contains the `KRCIDeployerRole.md` file and provides information about the EKS Deployer Role.

`eks/`: This directory contains Terraform scripts for creating and managing an EKS cluster. The .terraform-version file specifies the version of Terraform to use.

`iam/`: This directory contains Terraform scripts for creating and managing IAM role to deploy platform.

`LICENSE`: This is the license file for the project. It specifies the terms under which others can use, modify, and distribute your software.

`s3-backend/`: This directory contains the Terraform configuration for setting up an S3 backend. The S3 backend is used to store the Terraform state file in a centralized location, which is crucial for managing shared resources in a team environment.

`vpc/`: This directory contains Terraform scripts for creating and managing a VPC (Virtual Private Cloud).

Each of these components plays a crucial role in the project. The eks/, iam/, and vpc/ directories are particularly important as they contain the Terraform scripts for creating and managing the main resources of the project.

You can follow our [official documentation](https://docs.kuberocketci.io./docs/operator-guide/infrastructure-providers/aws/deploy-aws-eks) to get started with the deployment.

## Pre-Requisites

You need to have Terraform installed on your machine. Also, you should have an AWS account and the necessary [IAM role](./docs/KRCIDeployerRole.md) with permissions to create and manage AWS resources.

## Installation

To install, clone the repository to your local machine. You will then need to initialize Terraform using the `terraform init` command. Next, fill in the required fields in the tfvars file templates. Once the tfvars files are set up, you can run `terraform apply` with the appropriate tfvars file to create the resources.

## Usage

You can use the provided Terraform scripts to create and manage your AWS resources. The scripts are organized by resource type (VPC, EKS, IAM, etc.), and you can modify the .tf and .tfvars files as needed to fit your requirements. To apply the configurations, use `terraform apply` with the appropriate tfvars file.

## Terraform Version

The current Terraform version used in this project is 1.5.4. Please ensure you have this version installed to avoid any compatibility issues.

## License

This project is licensed under the Apache License 2.0. This permissive license allows you to freely use, modify, and distribute the software, subject to certain conditions. See the LICENSE file for more details.

## Contributing

Contributions are welcome! Feel free to submit a pull request with any changes or improvements to the scripts. Please ensure your code adheres to the existing style for consistency.
