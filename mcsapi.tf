data "helm_template" "coredns" {
  # Keep static version until more robust support is added.
  # This configuration is tested to only work with `1.43.3`.
  chart     = "oci://ghcr.io/coredns/charts/coredns:1.43.3"
  name      = "coredns"
  namespace = "kube-system"

  values = [
    templatefile("${path.module}/templates/coredns-values.yaml.tftpl", {
      service_subnet = var.network.subnets.service
    })
  ]
}
