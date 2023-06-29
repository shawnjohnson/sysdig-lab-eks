provider "sysdig" {
  sysdig_secure_url       = var.sysdig_secure_url
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

module "secure_for_cloud_aws" {
  source                           = "sysdiglabs/secure-for-cloud/aws//examples/single-account-apprunner"
  cloudtrail_is_multi_region_trail = false
}
