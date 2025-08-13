output "host" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
}

output "client_certificate" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  sensitive = true
}

output "client_key" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  sensitive = true
}

output "talosconfig" {
  value = {
    context   = var.cluster.name
    endpoints = data.talos_client_configuration.this.endpoints
    contexts = {
      (var.cluster.name) = {
        endpoints = data.talos_client_configuration.this.endpoints
        nodes     = local.all_ips
        ca        = talos_machine_secrets.this.client_configuration.ca_certificate
        crt       = talos_machine_secrets.this.client_configuration.client_certificate
        key       = talos_machine_secrets.this.client_configuration.client_key
      }
    }
    current-context = var.cluster.name
  }
  sensitive = true
}

output "kubeconfig" {
  value = {
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        name = var.cluster.name
        cluster = {
          certificate-authority-data = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
          server                     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
        }
      }
    ]
    contexts = [
      {
        name = var.cluster.name
        context = {
          cluster = var.cluster.name
          user    = var.cluster.name
        }
      }
    ]
    users = [
      {
        name = var.cluster.name
        user = {
          client-certificate-data = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
          client-key-data         = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
        }
      }
    ]
    current-context = var.cluster.name
  }
  sensitive = true
}

output "debug" {
  value = data.helm_template.talos_ccm.manifest
}