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

The current Terraform version used in this project is 1.5.7. Please ensure you have this version installed to avoid any compatibility issues.

## License

This project is licensed under the Apache License 2.0. This permissive license allows you to freely use, modify, and distribute the software, subject to certain conditions. See the LICENSE file for more details.

## Infrastructure Cost Analysis

This section provides a detailed breakdown of the estimated monthly costs for running the AWS infrastructure defined in this Terraform project.

### ⚠️ Important Disclaimers

- **Default Configuration Only**: This analysis is based on the **default configurations and values** defined in the Terraform code as of the analysis date
- **Configuration May Change**: Default values might be modified in future versions of this repository
- **Reference Purpose**: This cost breakdown is provided for **reference and calculation methodology** only
- **Always Consult Official Sources**: For accurate and up-to-date pricing, **always use the official [AWS Pricing Calculator](https://calculator.aws/)** and current AWS documentation
- **Regional Pricing Varies**: Costs shown are estimates for eu-central-1 (Frankfurt) region and may differ in other regions
- **Usage-Dependent**: Actual costs will vary based on real usage patterns, traffic, and operational requirements

### Default Configuration Summary

Based on the current Terraform code defaults:

- **Spot Node Group**: 1 desired, 1 min, 1 max (r5.xlarge/r5.2xlarge mixed instances)
- **On-Demand Node Group**: 0 desired, 0 min, 0 max (r5.xlarge)
- **EKS Version**: 1.30
- **Instance Types**: r5.xlarge primary, r5.2xlarge backup
- **EBS Volume**: 30GB GP3 per node
- **Scheduling**: 6 AM - 6 PM UTC, Monday-Friday
- **NAT Gateway**: Single gateway for cost optimization

### Monthly Cost Breakdown

| Resource Category | Resource Type | Quantity | Monthly Cost (USD) | Details |
|-------------------|---------------|----------|-------------------|---------|
| **EKS Cluster** | Control Plane | 1 | $72.00 | Standard support ($0.10/hour) |
| **Compute** | r5.xlarge (spot) | 1 | $55.00 | Default spot instance (desired: 1) |
| **Compute** | r5.2xlarge (spot) | 0 | $0.00 | Mixed instance policy (standby) |
| **Compute** | r5.xlarge (on-demand) | 0 | $0.00 | On-demand pool (desired: 0) |
| **Load Balancer** | Application Load Balancer | 1 | $25.50 | $0.027/hour + $0.008/LCU-hour |
| **Storage** | EBS GP3 (30GB per node) | 1 | $3.60 | $0.12/GB/month |
| **DNS** | Route 53 Hosted Zone | 1 | $0.50 | $0.50/month per zone |
| **DNS** | Route 53 DNS Queries | 1M | $0.40 | $0.40/million queries |
| **Storage** | S3 Standard (State) | 1GB | $0.02 | Terraform state storage |
| **Database** | DynamoDB (State Lock) | 1 | $0.65 | 1 RCU + 1 WCU |
| **Certificates** | ACM SSL Certificate | 1 | $0.00 | Free when used with ALB |
| **Networking** | VPC & Subnets | 1 | $0.00 | No additional cost |
| **Networking** | NAT Gateway | 1 | $37.96 | $0.052/hour (730 hours) |
| **Networking** | Data Transfer | 10GB | $0.90 | $0.09/GB outbound |
| **Monitoring** | CloudWatch Logs | 5GB | $2.50 | $0.50/GB ingested |
| **Security** | IAM Roles & Policies | ~25 | $0.00 | No additional cost |

### Total Estimated Monthly Cost: **$199.03 USD**

### How to Calculate Your Own Costs

To calculate accurate costs for your specific configuration:

1. **Use Official AWS Pricing Calculator**: Visit <https://calculator.aws/> and select your target region
2. **Check Current Default Values**: Review the `variables.tf` files in each module directory:
   - `eks/variables.tf` - Instance types, node counts, cluster version
   - `vpc/variables.tf` - VPC configuration, NAT gateway settings
   - `s3-backend/variables.tf` - S3 and DynamoDB settings
3. **Account for Your Usage Patterns**: Consider your actual traffic, storage needs, and operational hours
4. **Monitor Regional Pricing**: AWS pricing can vary by region and change over time
5. **Factor in Spot Pricing Fluctuations**: Spot instance prices change based on supply and demand

### Pricing Assumptions (Reference Only)

**⚠️ These are estimates based on default configuration - always verify current pricing**

- **Region**: eu-central-1 (Frankfurt)
- **Analysis Date**: July 2025
- **Instance Uptime**: 24/7 operation (730 hours/month)
- **Spot Instance Availability**: 95% availability assumed
- **Data Transfer**: 10GB outbound traffic per month
- **DNS Queries**: 1 million queries per month
- **Storage**: Minimal S3 usage for Terraform state
- **Monitoring**: Basic CloudWatch logging
- **Scheduled Scaling**: Applied (6 AM - 6 PM UTC, MON-FRI)

### Variable Costs

The following costs may vary based on actual usage:

- **Data Transfer**: Scales with traffic volume
- **DNS Queries**: Scales with application usage
- **EBS Storage**: Depends on workload requirements
- **CloudWatch**: Depends on logging verbosity
- **Spot Instance Pricing**: Fluctuates based on demand

### Cost Monitoring Recommendations

1. Enable AWS Cost Explorer for detailed cost tracking
2. Set up billing alerts for budget overruns
3. Use AWS Trusted Advisor for cost optimization suggestions
4. Monitor spot instance interruption rates
5. Review and optimize data transfer patterns

### 📋 Cost Calculation Checklist

Before deploying, ensure you:

- [ ] Review current default values in `variables.tf` files
- [ ] Use the [AWS Pricing Calculator](https://calculator.aws/) for your target region
- [ ] Account for your specific usage patterns and requirements
- [ ] Set up AWS Cost Explorer and billing alerts
- [ ] Consider reserved instances for predictable workloads
- [ ] Monitor spot instance pricing trends in your region

---

**⚠️ IMPORTANT**: This cost analysis is provided as a reference methodology only. AWS pricing changes frequently, and actual costs depend on numerous factors including usage patterns, regional variations, and current market conditions. Always consult official AWS pricing sources and use the AWS Pricing Calculator for accurate, up-to-date cost estimates before making deployment decisions.

## Contributing

Contributions are welcome! Feel free to submit a pull request with any changes or improvements to the scripts. Please ensure your code adheres to the existing style for consistency.
