locals {
  # Construct node image from KIND release version
  # Format: kindest/node:v1.31.0
  node_image = "kindest/node:${var.kind_release_version}"

  # Merge tags with module-specific metadata
  cluster_tags = merge(
    var.common_tags,
    {
      cluster_name = var.kind_cluster_name
      cluster_type = var.cluster_type
      environment  = var.env
      region       = var.target_region
      managed_by   = "terraform"
    }
  )
}

resource "kind_cluster" "this" {
  name            = var.kind_cluster_name
  node_image      = local.node_image
  wait_for_ready  = true
  kubeconfig_path = pathexpand("~/.kube/config")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Control plane node with port mappings for Traefik ingress
    node {
      role = "control-plane"

      # Port mapping for HTTP traffic (Traefik NodePort 30080 -> Host 80)
      extra_port_mappings {
        container_port = 30080
        host_port      = 80
        protocol       = "TCP"
      }

      # Port mapping for HTTPS traffic (Traefik NodePort 30443 -> Host 443)
      extra_port_mappings {
        container_port = 30443
        host_port      = 443
        protocol       = "TCP"
      }

      # Labels for workload scheduling
      labels = {
        "node-role" = "control-plane"
        "env"       = var.env
      }
    }

    # Worker node 1
    node {
      role = "worker"

      labels = {
        "node-role" = "worker"
        "env"       = var.env
      }
    }

    # Worker node 2
    node {
      role = "worker"

      labels = {
        "node-role" = "worker"
        "env"       = var.env
      }
    }
  }
}
