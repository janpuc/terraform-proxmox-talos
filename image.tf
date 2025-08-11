locals {
  latest_talos_version = element(
    data.talos_image_factory_versions.stable.talos_versions,
    length(data.talos_image_factory_versions.stable.talos_versions) - 1
  )
  talos_version = coalesce("v${var.cluster.talos_version}", local.latest_talos_version)

  default_talos_extensions = sort(["qemu-guest-agent", "iscsi-tools", "util-linux-tools"])

  download_amd64_iso = anytrue([for n in local.all_nodes_config : n.cpu.architecture == "amd64" && try(n.image.file_id, "") == null])
  download_arm64_iso = anytrue([for n in local.all_nodes_config : n.cpu.architecture == "arm64" && try(n.image.file_id, "") == null])
}

data "talos_image_factory_versions" "stable" {
  filters = {
    stable_versions_only = true
  }
}

data "talos_image_factory_extensions_versions" "all_nodes" {
  for_each = local.all_nodes_config

  talos_version = local.talos_version
  filters = {
    names = sort(try(concat(local.default_talos_extensions, each.value.image.extensions), local.default_talos_extensions))
  }
}

resource "talos_image_factory_schematic" "all_nodes" {
  for_each = local.all_nodes_config

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.all_nodes[each.key].extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "all_nodes" {
  for_each = local.all_nodes_config

  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.all_nodes[each.key].id
  platform      = "nocloud"
  architecture  = each.value.cpu.architecture
}

data "talos_image_factory_extensions_versions" "amd64" {
  count = local.download_amd64_iso ? 1 : 0

  talos_version = local.talos_version
  filters = {
    names = local.default_talos_extensions
  }
}

resource "talos_image_factory_schematic" "amd64" {
  count = local.download_amd64_iso ? 1 : 0

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.amd64[count.index].extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "amd64" {
  count = local.download_amd64_iso ? 1 : 0

  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.amd64[count.index].id
  platform      = "nocloud"
  architecture  = "amd64"
}

resource "proxmox_virtual_environment_download_file" "amd64" {
  count = local.download_amd64_iso ? 1 : 0

  node_name           = var.proxmox.node_name
  content_type        = "iso"
  datastore_id        = var.proxmox.iso_datastore
  file_name           = "talos-amd64-${local.talos_version}.iso"
  overwrite           = false
  overwrite_unmanaged = true
  upload_timeout      = 3600
  url                 = data.talos_image_factory_urls.amd64[count.index].urls.iso_secureboot
}

data "talos_image_factory_extensions_versions" "arm64" {
  count = local.download_arm64_iso ? 1 : 0

  talos_version = local.talos_version
  filters = {
    names = local.default_talos_extensions
  }
}

resource "talos_image_factory_schematic" "arm64" {
  count = local.download_arm64_iso ? 1 : 0

  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.arm64[count.index].extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "arm64" {
  count = local.download_arm64_iso ? 1 : 0

  talos_version = local.talos_version
  schematic_id  = talos_image_factory_schematic.arm64[count.index].id
  platform      = "nocloud"
  architecture  = "arm64"
}

resource "proxmox_virtual_environment_download_file" "arm64" {
  count = local.download_arm64_iso ? 1 : 0

  node_name           = var.proxmox.node_name
  content_type        = "iso"
  datastore_id        = var.proxmox.iso_datastore
  file_name           = "talos-arm64-${local.talos_version}.iso"
  overwrite           = false
  overwrite_unmanaged = true
  upload_timeout      = 3600
  url                 = data.talos_image_factory_urls.arm64[count.index].urls.iso_secureboot
}
