## Requirements

The following requirements are needed by this module:

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (~>3.0)

- <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) (~>0.80)

- <a name="requirement_talos"></a> [talos](#requirement\_talos) (0.9.0-alpha.0)

## Providers

The following providers are used by this module:

- <a name="provider_helm"></a> [helm](#provider\_helm) (~>3.0)

- <a name="provider_http"></a> [http](#provider\_http)

- <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) (~>0.80)

- <a name="provider_talos"></a> [talos](#provider\_talos) (0.9.0-alpha.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [proxmox_virtual_environment_download_file.amd64](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) (resource)
- [proxmox_virtual_environment_download_file.arm64](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file) (resource)
- [proxmox_virtual_environment_vm.cluster_node](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) (resource)
- [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/cluster_kubeconfig) (resource)
- [talos_image_factory_schematic.all_nodes](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/image_factory_schematic) (resource)
- [talos_image_factory_schematic.amd64](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/image_factory_schematic) (resource)
- [talos_image_factory_schematic.arm64](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/image_factory_schematic) (resource)
- [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_bootstrap) (resource)
- [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_configuration_apply) (resource)
- [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_secrets) (resource)
- [helm_template.talos_ccm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template) (data source)
- [http_http.cluster_health](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)
- [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/client_configuration) (data source)
- [talos_image_factory_extensions_versions.all_nodes](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_extensions_versions) (data source)
- [talos_image_factory_extensions_versions.amd64](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_extensions_versions) (data source)
- [talos_image_factory_extensions_versions.arm64](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_extensions_versions) (data source)
- [talos_image_factory_urls.all_nodes](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_urls) (data source)
- [talos_image_factory_urls.amd64](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_urls) (data source)
- [talos_image_factory_urls.arm64](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_urls) (data source)
- [talos_image_factory_versions.stable](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_versions) (data source)
- [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/machine_configuration) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_cluster"></a> [cluster](#input\_cluster)

Description: Cluster configuration.

Type:

```hcl
object({
    name               = string
    talos_version      = optional(string, "1.10.6")
    talos_ccm_version  = optional(string, "0.5.0")
    kubernetes_version = optional(string, "1.33.3")
  })
```

### <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane)

Description: Control plane node group configuration.

Type:

```hcl
object({
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
```

### <a name="input_network"></a> [network](#input\_network)

Description: Global network configuration.

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_cilium_values"></a> [cilium\_values](#input\_cilium\_values)

Description: A map of configuration values for Cilium.

Type: `any`

Default:

```json
{
  "cgroup": {
    "autoMount": {
      "enabled": false
    },
    "hostRoot": "/sys/fs/cgroup"
  },
  "externalIPs": {
    "enabled": true
  },
  "hubble": {
    "tls": {
      "auto": {
        "method": "cronJob"
      }
    }
  },
  "ipam": {
    "mode": "kubernetes"
  },
  "k8sClientRateLimit": {
    "burst": 100,
    "qps": 50
  },
  "k8sServiceHost": "localhost",
  "k8sServicePort": 7445,
  "kubeProxyReplacement": true,
  "l2announcements": {
    "enabled": true
  },
  "operator": {
    "replicas": 1
  },
  "rollOutCiliumPods": true,
  "routingMode": "tunnel",
  "securityContext": {
    "capabilities": {
      "ciliumAgent": [
        "CHOWN",
        "KILL",
        "NET_ADMIN",
        "NET_RAW",
        "IPC_LOCK",
        "SYS_ADMIN",
        "SYS_RESOURCE",
        "DAC_OVERRIDE",
        "FOWNER",
        "SETGID",
        "SETUID"
      ],
      "cleanCiliumState": [
        "NET_ADMIN",
        "SYS_ADMIN",
        "SYS_RESOURCE"
      ]
    }
  },
  "tunnelProtocol": "vxlan"
}
```

### <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups)

Description: Worker node groups configuration.

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_proxmox"></a> [proxmox](#input\_proxmox)

Description: Proxmox confugration.

Type:

```hcl
object({
    node_name     = string
    iso_datastore = string
    datastore     = string
  })
```

Default:

```json
{
  "datastore": "local-lvm",
  "iso_datastore": "local",
  "node_name": "proxmox"
}
```

## Outputs

The following outputs are exported:

### <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate)

Description: n/a

### <a name="output_client_key"></a> [client\_key](#output\_client\_key)

Description: n/a

### <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate)

Description: n/a

### <a name="output_host"></a> [host](#output\_host)

Description: n/a

### <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig)

Description: n/a

### <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig)

Description: n/a
