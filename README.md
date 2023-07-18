# Sysdig Secure Demo Lab for EKS

This project is a simple Terraform module that builds an EKS cluster (and required VPC infrastructure), and installs Sysdig Secure with a Helm chart (sysdig-deploy).

The helm values are stored in a standard `values.yaml` under a `\helm` subfolder. Notice the sysdig-agent.tf uses the set parameters to pass the Secret values, allowing our values file to be stored and versioned. It is a best-practice to use an tool for Secrets management, especially as your team and organization grow. For simplicity in this lab project, I have a `terraform.tfvars` file with secret configuration values.

Example
```tf

# required for sysdig provider
sysdig_secure_api_token = "XXXXXX"
sysdig_secure_url = "https://us2.app.sysdig.com"

# used by sysdig helm chart
sysdig_region = "us2"
sysdig_agent_access_key = "YYYYYY"
eks_cluster_name = "my-eks-lab"

```

## Updating

When updating the sysdig-deploy chart version, you should run a `terraform init -upgrade` to ensure the latest module is downloaded and applied.
Ref: https://developer.hashicorp.com/terraform/cli/commands/init#upgrade-1