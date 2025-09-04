# Repository Structure

This repository is organized into several key directories, each serving a specific purpose in the AWS EKS deployment process. Understanding this structure is essential for effectively working with and contributing to the codebase.

## Root Directory

- `.pre-commit-config.yaml`: Configuration for pre-commit hooks that run automatically on commit to enforce code standards and prevent problematic commits.
- `README.md`: Main documentation file with an overview of the project, installation instructions, and usage guidelines.
- `LICENSE`: Apache License 2.0 file specifying the terms under which this software can be used, modified, and distributed.
- `atlantis.yaml`: Configuration for Atlantis, a tool for Terraform automation in CI/CD pipelines.

## Core Infrastructure Modules

### `s3-backend/`

Contains Terraform configurations for setting up an S3 backend to store Terraform state files centrally. This is crucial for team environments where multiple people may be managing the same infrastructure.

**Key files:**
- `main.tf`: Main Terraform configuration for S3 bucket and DynamoDB table creation
- `variables.tf`: Input variables declaration
- `outputs.tf`: Output values definition
- `example.tfvars` & `template.tfvars`: Example and template variable files

### `iam/`

Contains Terraform scripts for creating and managing IAM roles with the necessary permissions for deploying and managing the platform.

**Key files:**
- `main.tf`: IAM role and policy definitions
- `data.tf`: Data sources for IAM configurations
- `variables.tf`: Input variables for customization
- `outputs.tf`: Output values including role ARNs
- `template.tfvars`: Template for required variables

### `vpc/`

Contains Terraform scripts for creating and managing the Virtual Private Cloud (VPC), including subnets, routing tables, and network security components.

**Key files:**
- `main.tf`: VPC infrastructure definitions
- `variables.tf`: Customization variables for network settings
- `outputs.tf`: Outputs including VPC ID and subnet IDs
- `example.tfvars` & `template.tfvars`: Example and template configuration files

### `eks/`

Contains Terraform scripts for creating and managing the Elastic Kubernetes Service (EKS) cluster, including node groups, security groups, and add-ons.

**Key files:**
- `main.tf`: EKS cluster configuration
- `acm.tf`: AWS Certificate Manager configurations
- `alb.tf`: Application Load Balancer settings
- `irsa.tf`: IAM Roles for Service Accounts configuration
- `schedulers.tf`: Node group scaling schedulers
- `variables.tf`: Input variables for cluster customization
- `outputs.tf`: Cluster outputs including endpoint and auth data
- `example.tfvars` & `template.tfvars`: Example and template configuration files

### `argo-cd/`

Contains Terraform scripts for configuring AWS IAM Roles for Argo CD, supporting both internal and external cluster integration scenarios.

**Key files:**
- `main.tf`: Argo CD IAM role configurations
- `data.tf`: Data sources for Argo CD integration
- `variables.tf`: Input variables for customization
- `outputs.tf`: Role ARN outputs
- `example.tfvars` & `terraform.tfvars`: Example and actual variable files

## Documentation

### `docs/`

Contains additional documentation files:

- `KRCIDeployerRole.md`: Detailed information about the EKS Deployer Role
- `UPGRADE-20.0.md`: Guidelines for upgrading to version 20.0

## Deployment Flow

The repository is designed to be used in the following sequence:

1. Set up the S3 backend for Terraform state management (`s3-backend/`)
2. Create the necessary IAM roles for deployment (`iam/`)
3. Create the VPC and network infrastructure (`vpc/`)
4. Deploy the EKS cluster with all its components (`eks/`)
5. (Optional) Configure Argo CD IAM roles for GitOps workflows (`argo-cd/`)

Each step depends on the outputs from the previous steps, creating a cohesive infrastructure deployment pipeline.
