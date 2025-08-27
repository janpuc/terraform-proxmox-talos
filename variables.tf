variable "proxmox" {
  description = "Proxmox confugration."
  type = object({
    cluster_name  = string
    node_name     = string
    iso_datastore = string
    datastore     = string
  })
  default = {
    cluster_name  = ""
    node_name     = "proxmox"
    iso_datastore = "local"
    datastore     = "local-lvm"
  }
}

variable "cluster" {
  description = "Cluster configuration."
  type = object({
    name                     = string
    id                       = optional(number, 1)
    talos_version            = optional(string, "1.10.6")
    talos_ccm_version        = optional(string, "0.5.0")
    kubernetes_version       = optional(string, "1.33.3")
    gateway_api_crds_version = optional(string, "1.5.0")
    multi_cluster            = optional(bool, false)
    cilium_ca_crt            = optional(string, "")
    cilium_ca_key            = optional(string, "")
  })
}

variable "network" {
  description = "Global network configuration."
  type = object({
    gateway  = string
    kube_vip = string
    dns = optional(object({
      servers = list(string)
      domain  = string
    }), null)
    subnets = object({
      vm      = string
      pod     = optional(string, "10.208.0.0/16")
      service = optional(string, "10.209.0.0/16")
    })
    vlan_id = optional(number)
    bridge  = optional(string, "vmbr0")
  })

  # TODO: Fix later....
  # validation {
  #   condition     = var.network.vlan_id == null || (try(var.network.vlan_id, 0) >= 1 && try(var.network.vlan_id, 0) <= 4094)
  #   error_message = "VLAN ID must be between 1-4094 or null."
  # }
}

variable "control_plane" {
  description = "Control plane node group configuration."
  type = object({
    count      = number
    base_vm_id = number
    cpu = object({
      architecture = optional(string, "amd64")
      cores        = number
      numa         = optional(bool, false)
      type         = optional(string, "x86-64-v2-AES")
      affinity     = optional(string)
    })
    memory = object({
      dedicated = number
      floating  = optional(number)
    })
    disk = object({
      size = number
      ssd  = optional(bool, true)
    })
    image = optional(object({
      extensions     = optional(list(string))
      file_id        = optional(string)
      kernel_modules = optional(list(string))
      sysctls        = optional(map(string))
    }), {})
    hostpci = optional(object({
      id = optional(string)
    }), {})
    overrides = optional(map(object({
      cpu = optional(object({
        architecture = optional(string)
        cores        = optional(number)
        numa         = optional(bool)
        type         = optional(string)
        affinity     = optional(string)
      }), {})
      memory = optional(object({
        dedicated = optional(number)
        floating  = optional(number)
      }), {})
      disk = optional(object({
        size = optional(number)
        ssd  = optional(bool)
      }), {})
      image = optional(object({
        extensions     = optional(list(string))
        file_id        = optional(string)
        kernel_modules = optional(list(string))
        sysctls        = optional(map(string))
      }), {})
      hostpci = optional(object({
        id = optional(string)
      }), {})
    })), {})
  })

  validation {
    condition     = var.control_plane.count > 0 && var.control_plane.count % 2 == 1
    error_message = "Control plane count must be an odd number grater than 0."
  }

  validation {
    condition     = var.control_plane.cpu.cores >= 1
    error_message = "CPU cores must be at least 1."
  }

  validation {
    condition     = contains(["amd64", "arm64"], var.control_plane.cpu.architecture)
    error_message = "CPU architecture must be either 'amd64' or 'amd64'."
  }

  validation {
    condition     = var.control_plane.memory.dedicated >= 1024
    error_message = "Dedicated memory must be at least 1024MB (1GB)."
  }

  validation {
    condition     = var.control_plane.memory.floating == null || coalesce(var.control_plane.memory.floating, 0) >= var.control_plane.memory.dedicated
    error_message = "Floating memory must be larger or equal to dedicated memory or null."
  }

  validation {
    condition     = var.control_plane.disk.size >= 10
    error_message = "Disk size must be at least 10GB."
  }
}

variable "node_groups" {
  description = "Worker node groups configuration."
  type = map(object({
    count      = number
    base_vm_id = number
    cpu = object({
      architecture = optional(string, "amd64")
      cores        = number
      numa         = optional(bool, false)
      type         = optional(string, "x86-64-v2-AES")
      affinity     = optional(string)
    })
    memory = object({
      dedicated = number
      floating  = optional(number)
    })
    disk = object({
      size = number
      ssd  = optional(bool, true)
    })
    image = optional(object({
      extensions     = optional(list(string))
      file_id        = optional(string)
      kernel_modules = optional(list(string))
      sysctls        = optional(map(string))
    }), {})
    hostpci = optional(object({
      id = optional(string)
    }), {})
    overrides = optional(map(object({
      cpu = optional(object({
        architecture = optional(string)
        cores        = optional(number)
        numa         = optional(bool)
        type         = optional(string)
        affinity     = optional(string)
      }), {})
      memory = optional(object({
        dedicated = optional(number)
        floating  = optional(number)
      }), {})
      disk = optional(object({
        size = optional(number)
        ssd  = optional(bool)
      }), {})
      image = optional(object({
        extensions     = optional(list(string))
        file_id        = optional(string)
        kernel_modules = optional(list(string))
        sysctls        = optional(map(string))
      }), {})
      hostpci = optional(object({
        id = optional(string)
      }), {})
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for group_name, group in var.node_groups : group.count >= 0
    ])
    error_message = "Node group count cannot be negative."
  }

  validation {
    condition = alltrue([
      for group_name, group in var.node_groups : group.cpu.cores >= 1
    ])
    error_message = "CPU cores must be at least 1 in all node groups."
  }

  validation {
    condition = alltrue([
      for group_name, group in var.node_groups : contains(["amd64", "arm64"], group.cpu.architecture)
    ])
    error_message = "CPU architecture must be either 'amd64' or 'arm64' in all node groups."
  }

  validation {
    condition = alltrue([
      for group_name, group in var.node_groups : group.memory.dedicated >= 1024
    ])
    error_message = "Dedicated memory must be at least 1024MB (1GB) in all node groups."
  }

  validation {
    condition = alltrue([
      for group_name, group in var.node_groups : group.memory.floating == null || coalesce(group.memory.floating, 0) >= group.memory.dedicated
    ])
    error_message = "Floating memory must be larger or equal to dedicated memory or null in all node groups."
  }

  validation {
    condition = alltrue([
      for group_name, group in var.node_groups : group.disk.size >= 10
    ])
    error_message = "Disk size must be at least 10GB in all node groups."
  }
}
