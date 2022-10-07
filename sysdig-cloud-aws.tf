provider "sysdig" {
  sysdig_secure_url       = var.sysdig_secure_url
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

module "secure_for_cloud_aws_single_account_k8s" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/single-account-k8s"
  benchmark_regions	= ["us-east-1"]
  cloudtrail_is_multi_region_trail = false
}