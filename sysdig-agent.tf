resource "helm_release" "sysdig-agent" {
  name       = "sysdig"
  namespace  = "sysdig-agent"
  create_namespace = true
  repository = "https://charts.sysdig.com"
  chart      = "sysdig-deploy"
  version    = "~> 1.7"
  values = [
    "${file("helm/sysdig-deploy.values.yaml")}"
  ]

  set {
    name = "global.sysdig.accessKey"
    value = "${var.sysdig_agent_access_key}"
  }
  
  set {
    name = "global.sysdig.region"
    value = "${var.sysdig_region}"
  }
 
  set {
    name = "global.clusterConfig.name"
    value = "${var.eks_cluster_name}"
  }
}

resource "helm_release" "sysdig-admission" {
  name       = "sysdig-admission-controller"
  namespace  = "sysdig-admission-controller"
  create_namespace = true
  repository = "https://charts.sysdig.com"
  chart      = "admission-controller"
  version    = "~> 0.7"

  values = [ <<EOF
sysdig:
  url: ${var.sysdig_secure_url}/
  secureAPIToken: ${var.sysdig_secure_api_token}
clusterName: ${var.eks_cluster_name}
# Disable legacy scanner gate
scanner.enabled: false
features:
  k8sAuditDetections: true
EOF
  ]

}