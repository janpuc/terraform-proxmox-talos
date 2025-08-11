resource "talos_machine_secrets" "this" {
  talos_version = local.talos_version
}

data "talos_machine_configuration" "this" {
  for_each = local.all_nodes

  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.network.kube_vip}:6443"
  machine_type     = each.value.type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    templatefile("${path.module}/templates/machineconfig.yaml.tftpl", {
      hostname           = each.key,
      type               = each.value.type,
      kernel_modules     = try(each.value.image.kernel_modules, null)
      sysctls            = try(each.value.image.sysctls, null)
      kubernetes_version = var.cluster.kubernetes_version,
      installer_image    = data.talos_image_factory_urls.all_nodes[each.key].urls.installer_secureboot,
      vm_subnet          = var.network.subnets.vm,
      pod_subnet         = var.network.subnets.pod,
      service_subnet     = var.network.subnets.service,
      kube_vip           = var.network.kube_vip,
      inline_manifests = [
        {
          name = "cilium-install"
          contents = templatefile("${path.module}/templates/cilium-install.yaml.tftpl", {
            cilium_values = yamlencode(var.cilium_values)
          })
        }
      ]
    }),
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.control_plane_ips
}

resource "talos_machine_configuration_apply" "this" {
  for_each = local.all_nodes

  client_configuration        = data.talos_client_configuration.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = local.all_nodes[each.key].ip

  on_destroy = {
    graceful = false # INFO: `true` for upgrade, `false` for destroy
    reboot   = false
    reset    = true
  }
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.this]

  client_configuration = data.talos_client_configuration.this.client_configuration
  node                 = local.control_plane_ips[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = data.talos_client_configuration.this.client_configuration
  node                 = var.network.kube_vip
}
