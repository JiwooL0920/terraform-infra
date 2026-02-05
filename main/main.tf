module "homelab-kind" {
  source               = "../modules/homelab/tf-kind-base"
  cluster_type         = var.cluster_type
  kind_release_version = var.kind_release_version
  kind_cluster_name    = var.kind_cluster_name
  target_region        = var.target_region
  env                  = var.env
  common_tags = merge(
    var.common_tags,
    {
      Environment = upper(var.env)
    }
  )
}
