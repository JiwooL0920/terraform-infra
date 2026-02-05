output "cluster_name" {
  description = "Name of the KIND cluster"
  value       = kind_cluster.this.name
}

output "cluster_id" {
  description = "ID of the KIND cluster"
  value       = kind_cluster.this.id
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = kind_cluster.this.kubeconfig_path
}

output "client_certificate" {
  description = "Client certificate for cluster authentication"
  value       = kind_cluster.this.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for cluster authentication"
  value       = kind_cluster.this.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = kind_cluster.this.cluster_ca_certificate
  sensitive   = true
}

output "endpoint" {
  description = "Kubernetes API endpoint"
  value       = kind_cluster.this.endpoint
}

output "kubectl_context" {
  description = "kubectl context name for this cluster"
  value       = "kind-${kind_cluster.this.name}"
}

output "cluster_info" {
  description = "Summary of cluster configuration"
  value = {
    name         = kind_cluster.this.name
    endpoint     = kind_cluster.this.endpoint
    node_image   = local.node_image
    environment  = var.env
    cluster_type = var.cluster_type
  }
}
