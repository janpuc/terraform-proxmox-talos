data "helm_template" "talos_ccm" {
  chart = "oci://ghcr.io/siderolabs/charts/talos-cloud-controller-manager:${var.cluster.talos_ccm_version}"
  name  = "talos-cloud-controller-manager"
  namespace = "kube-system"

  values = [
    templatefile("${path.module}/templates/talos-ccm.yaml.tftpl", {
      node_groups = compact([ 
        for ng, ng_config in local.all_ng_map : "${ng}"
      ])
    })
  ]
}
