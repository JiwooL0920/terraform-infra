variable "env" {
  type        = string
  description = "value of the environment (dev, uat, prod)"
}

variable "cluster_type" {
  type        = string
  description = "role of cluster(services, apps, deployments)"
}

variable "kind_release_version" {
  type        = string
  description = "kind release version"
}

variable "kind_cluster_name" {
  type        = string
  description = "value of the eks cluster name"
}

variable "target_region" {
  type        = string
  description = "value of the target region"
  default     = "us-west-1"
}

variable "common_tags" {
  type = map(string)
  default = {
    Application_ID = "homelab"
    Environment    = "DEV"
    Created_by     = "terraform"
    Contact        = "jiwool0920@gmail.com"
  }
  description = "Tags passed to resources that supports them"
}
