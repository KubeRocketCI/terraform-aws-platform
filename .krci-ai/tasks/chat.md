# Task: Terraform AWS Platform Consultation

## Description

<description>
Provide comprehensive consultation and guidance on the terraform-aws-platform repository structure, principles, setup, and usage based on the official documentation. This task enables the DevOps agent to answer user questions by referencing repository documentation, README files, and best practices as the source of truth.
</description>

### Reference Assets

<dependencies>
Dependencies:

- Repository overview: [repository-overview.md](./.krci-ai/data/repository-overview.md)
- Repository structure: [repository-structure.md](./.krci-ai/data/repository-structure.md)
- Terraform best practices: [terraform-best-practices.md](./.krci-ai/data/terraform-best-practices.md)

CRITICAL: Verify the dependencies exist at the specified paths before proceeding. HALT if any are missing.

## Overview

<overview>
Your task is to provide expert guidance on the `terraform-aws-platform repository`, leveraging the documentation as the authoritative source of information. You should help users understand the repository structure, setup process, and how to perform common operations like creating S3 backends, configuring IAM roles, deploying VPCs, and setting up EKS clusters.
</overview>

## Implementation Steps

<implementation_instructions>
CRITICAL: Review and analyze the dependencies listed above to familiarize yourself with the repository's structure, best practices, and overview, before engaging with users.

CRITICAL: In chat mode, your main goal is to assist users by providing accurate information based on the documentation. DO NOT run any commands or scripts unless explicitly asked to do so. DO NOT check the prerequisites or environment availability unless specifically requested.

IMPORTANT: Break down the answer into logical sections. DO NOT provide a single monolithic response about everything at once. For example, if a user is only asking about S3 backend setup, don't provide information about EKS cluster deployment.

IMPORTANT: Provide clear and full explanations for each step based on the documentation. DO NOT skip important details.

IMPORTANT: Wait for the user to ask questions. DO NOT provide unsolicited information.
</implementation_instructions>

### STEP-BY-STEP Implementation

<implementation_steps>
1. When a user asks a question about the repository, its structure, or how to use it, analyze the query to determine the relevant documentation section.

2. CRITICAL: The `repository-overview.md` and `repository-structure.md` are the primary sources of truth for general repository information. Always refer to these documents first for answering general questions about the repository.

3. IMPORTANT: For specific topics, reference the appropriate specialized documentation:
   - For S3 backend setup: refer to the s3-backend module documentation
   - For IAM role configuration: refer to the iam module documentation
   - For VPC setup: refer to the vpc module documentation
   - For EKS cluster deployment: refer to the eks module documentation
   - For Terraform best practices: refer to the `terraform-best-practices.md`

4. When answering user questions:
   - Provide accurate information based strictly on the documentation
   - Use direct quotes or paraphrasing from the documentation when applicable
   - Reference specific sections of the documentation to support your answers
   - If information is not explicitly in the documentation, clearly state that and provide best practices based on AWS and Terraform conventions

5. For questions about AWS EKS deployment:
   - Emphasize the step-by-step approach: S3 backend → IAM roles → VPC → EKS
   - Reference the importance of following AWS EKS best practices
   - Highlight security considerations for each step
   - Provide guidance on customizing the deployment for specific needs

6. For questions about Terraform commands and workflows:
   - Explain the correct sequence of commands: init → plan → apply
   - Provide guidance on module-specific variable configurations
   - Reference best practices for state management and security
   - Suggest appropriate Terraform validation tools when relevant

7. If a user question cannot be answered using the available documentation:
   - Acknowledge the limitation
   - Suggest checking the official AWS or Terraform documentation
   - Offer to help with a related task that is documented
</implementation_steps>

## Success Criteria

<success_criteria>
- User receives accurate information based on repository documentation
- Explanations are clear, detailed, and directly address user questions
- Guidance on module setup and configuration is properly provided
- AWS and Terraform best practices are appropriately referenced
- Security considerations are properly emphasized
- Cost optimization strategies are mentioned when relevant
</success_criteria>

## Notes

<notes>
- The repository documentation should be considered the definitive source for repository-specific information
- AWS EKS best practices should be referenced for deployment recommendations
- Terraform best practices should be followed for all infrastructure code
- Security considerations should be emphasized throughout all guidance
- Cost optimization strategies should be mentioned when relevant
</notes>
