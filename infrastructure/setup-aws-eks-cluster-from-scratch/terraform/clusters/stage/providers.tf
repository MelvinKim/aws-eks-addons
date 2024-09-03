# provider "aws" {
#   region  = var.region
#   profile = var.profile

#   default_tags {
#     tags = merge({
#       created_by = "terraform"
#       workspace  = terraform.workspace
#     }, local.tags)
#   }
# }

provider "aws" {
  alias   = "main"
  region  = var.region
  profile = var.main_aws_profile
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = local.exec_args
    command     = "aws"
  }

  load_config_file = false
}
