resource "proxmox_virtual_environment_vm" "cluster_node" {
  for_each = local.all_nodes_config

  name        = each.value.name
  node_name   = var.proxmox.node_name
  vm_id       = each.value.vm_id
  tags        = [each.value.group, "talos"]
  description = "Talos Linux ${each.value.group} node"

  machine       = each.value.cpu.architecture == "arm64" ? "virt" : "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"

  efi_disk {
    datastore_id = var.proxmox.datastore
    file_format  = "raw"
    type         = "4m"
  }

  tpm_state {
    version = "v2.0"
  }

  boot_order = ["scsi0", "ide3"]

  cdrom {
    file_id = coalesce(try(each.value.image.file_id, ""), each.value.cpu.architecture == "arm64" ? try(proxmox_virtual_environment_download_file.arm64[0].id, "") : try(proxmox_virtual_environment_download_file.amd64[0].id, ""))
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
    timeout = "15m"
  }

  initialization {
    datastore_id = var.proxmox.datastore

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    dynamic "dns" {
      for_each = var.network.dns != null ? [1] : []
      content {
        servers = var.network.dns.servers
        domain  = var.network.dns.domain
      }
    }
  }

  cpu {
    cores    = each.value.cpu.cores
    type     = try(each.value.cpu.type, "x86-64-v2-AES")
    numa     = try(each.value.cpu.numa, false)
    affinity = try(each.value.cpu.affinity, null)
  }

  memory {
    dedicated = each.value.memory.dedicated
    floating  = try(each.value.memory.floating, null)
  }

  disk {
    datastore_id = var.proxmox.datastore
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    cache        = "writethrough"
    file_format  = "raw"
    ssd          = try(each.value.disk.ssd, true)
    size         = each.value.disk.size
  }

  network_device {
    bridge  = var.network.bridge
    vlan_id = try(var.network.vlan_id, null)
  }

  dynamic "hostpci" {
    for_each = each.value.hostpci.id != null ? [1] : []
    content {
      device = "hostpci0"
      id     = each.value.hostpci.id
      rombar = true
    }
  }
}
