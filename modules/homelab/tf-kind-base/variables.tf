variable "kind_cluster_name" {
  type        = string
  description = "Name of the KIND cluster"
  default     = "dev-services-amer"
}

variable "kind_release_version" {
  type        = string
  description = "KIND release version (node image version)"
  default     = "v1.31.0"
}

variable "cluster_type" {
  type        = string
  description = "Type/role of cluster (services, apps, deployments)"
}

variable "env" {
  type        = string
  description = "Environment (dev, uat, prod)"
}

variable "target_region" {
  type        = string
  description = "Target region for resource tagging"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to resources (for metadata/organization)"
  default     = {}
}
