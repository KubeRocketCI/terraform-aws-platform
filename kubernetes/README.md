kubernetes
==========

Optional project to create Prerequisites for EDP deployment and deploy the required helm charts, namely:

* EDP and Keycloak secrets in the EKS cluster,
* Keycloak, Kiosk, NGINX Ingress Controller and finally EDP helm charts.

How-to-run
----------

1. Fill the input variables with the required values in the `terraform.tfvars` and `secrets.tfvars` files, refer to the `template.tfvars` as an example. Find the detailed description of the variables in the `variables.tf` file.
2. Apply the changes: `KUBE_CONFIG_PATH=/path/to/kubeconfig terraform apply -var-file=secrets.tfvars`.

Example:
--------

```bash
$ cd terraform-aws-platform-template/kubernetes
$ KUBE_CONFIG_PATH=../kubeconfig_test-eks terraform apply -var-file=secrets.tfvars
```
4. At this run Terraform will use the local backend to store state on the local filesystem, locks that state using system APIs, and performs operations locally. There are no strong requirements to store the resulted state file in the CVS, but it's possible at will since there is no sensitive data.
