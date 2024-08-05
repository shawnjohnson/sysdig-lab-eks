resource "helm_release" "sysdig-cluster" {
  count = 1
  name             = "cluster-shield"
  namespace        = "sysdig-agent"
  create_namespace = true
  chart            = "oci://quay.io/sysdig/cluster-shield"
  version          = "0.9.0-helm"
  values = [
    "${file("helm/sysdig-clustershield.values.yaml")}"
  ]

  set {
    name  = "cluster_shield.sysdig_endpoint.access_key"
    value = var.sysdig_agent_access_key
  }

  set {
    name  = "cluster_shield.sysdig_endpoint.api_url"
    value = var.sysdig_secure_url
  }

  set {
    name  = "cluster_shield.cluster_config.name"
    value = var.eks_cluster_name
  }
}