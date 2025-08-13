terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~>3.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~>0.80"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
  }
}
