output "cluster_name" {
  description = "Name of the KIND cluster"
  value       = module.homelab-kind.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.homelab-kind.endpoint
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = module.homelab-kind.kubeconfig_path
}

output "kubectl_context" {
  description = "kubectl context name for this cluster"
  value       = module.homelab-kind.kubectl_context
}

output "cluster_info" {
  description = "Summary of cluster configuration"
  value       = module.homelab-kind.cluster_info
}

output "flux_bootstrap_command" {
  description = "Command to bootstrap Flux on this cluster"
  value       = <<-EOT
    flux bootstrap github \
      --owner=<your-github-username> \
      --repository=fleet-infra \
      --branch=develop \
      --path=./clusters/stages/dev/clusters/services-amer \
      --personal
  EOT
}
