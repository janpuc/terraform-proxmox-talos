data "helm_template" "gateway_api_crds" {
  chart     = "oci://registry-1.docker.io/envoyproxy/gateway-crds-helm:${var.cluster.gateway_api_crds_version}"
  name      = "gateway-api-crds"
  namespace = "kube-system"

  values = [{
    crds = {
      gatewayAPI = {
        enabled = true
        channel = "experimental"
      }
    }
  }]
}
