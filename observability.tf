data "helm_template" "prometheus_operator_crds" {
  chart     = "oci://ghcr.io/prometheus-community/charts/prometheus-operator-crds:${var.cluster.prometheus_operator_crds_version}"
  name      = "prometheus-operator-crds"
  namespace = "kube-system"
}
