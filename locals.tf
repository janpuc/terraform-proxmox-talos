locals {
  all_ng_map = merge(
    tomap({ "control-plane" = merge({ for k, v in var.control_plane : k => v if(k != "overrides") }) }),
    merge({ for k, v in var.node_groups : k => v if(k != "overrides") })
  )

  all_node_overrides_map = merge(
    tomap({ "control-plane" = var.control_plane.overrides }),
    { for group_name, group_config in var.node_groups : group_name => group_config.overrides }
  )

  node_config_reserved_word_list = ["count", "base_vm_id", "overrides"]

  # INFO: This magic local automatically picks up new values added to node configuration and applies overrides.
  #       It is only functional for variables that are a layer deep, so extend it with caution.
  #       Example: `cpu.cores` will work while `cpu.cores.somevariable` will not.
  # TODO: Extend compatibility to flat variables like `cpu`.
  all_nodes_config = { for node in(flatten([
    for group_name, group_config in local.all_ng_map : [
      for i in range(group_config.count) : merge({
        name  = format("%s-%s-%02d", var.cluster.name, group_name, i + 1)
        group = group_name
        vm_id = group_config.base_vm_id + i + 1
        }, { for k0, v0 in group_config : k0 => merge({
          for k1, v1 in group_config[k0] : k1 => try(coalesce(
            try(local.all_node_overrides_map[group_name][group_config.base_vm_id + i + 1][k0][k1], null), v1
          ), null)
        })
        if(!contains(local.node_config_reserved_word_list, k0)) }
      )
    ]
  ])) : node.name => node }

  all_nodes = {
    for node, node_attributes in proxmox_virtual_environment_vm.cluster_node : node => merge({
      type = strcontains(node, "control-plane") ? "controlplane" : "worker"
      ip = one([
        for ip in flatten(node_attributes.ipv4_addresses) :
        ip if cidrcontains(var.network.subnets.vm, ip) &&
        ip != "127.0.0.1" &&
        ip != var.network.kube_vip
      ])
    }, local.all_nodes_config[node])
  }

  all_ips = compact([
    for node, node_values in local.all_nodes : local.all_nodes[node].ip
  ])

  control_plane_ips = compact([
    for node, node_values in local.all_nodes : local.all_nodes[node].type == "controlplane" ? local.all_nodes[node].ip : null
  ])

  worker_ips = compact([
    for node, node_values in local.all_nodes : local.all_nodes[node].type != "controlplane" ? local.all_nodes[node].ip : null
  ])
}
