variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "eks_cluster_name" {
  type = string
}

# For sysdig secure for cloud provider
variable "sysdig_secure_url" {
  type = string
}

# shared
variable "sysdig_secure_api_token" {
  type = string
  sensitive = true
}

# Sysdig helm chart
variable "sysdig_region" {
  type = string
}

variable "sysdig_agent_access_key" {
  type = string
  sensitive = true
}