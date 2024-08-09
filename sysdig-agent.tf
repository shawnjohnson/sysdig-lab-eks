resource "helm_release" "sysdig-agent" {
  count = 1
  name       = "sysdig"
  namespace  = "sysdig-agent"
  create_namespace = true
  repository = "https://charts.sysdig.com"
  chart      = "sysdig-deploy"
  version    = "~> 1.61"
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
