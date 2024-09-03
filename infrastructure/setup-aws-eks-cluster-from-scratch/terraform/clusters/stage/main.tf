module "vpc" {
  source = "../../modules/vpc"

  vpc_name = local.env_prefix
  cluster_name = "${local.env_prefix}-cluster"

  alb_tags = local.alb_tags
}

module "cluster" {
  source = "../../modules/eks-cluster"

  # depends_on = [ module.vpc ]

  cluster_name = "${local.env_prefix}-cluster"
  cluster_version = "1.30"
  cluster_instance_types = ["t3a.medium"]
  cluster_max_size = 3
  cluster_min_size = 1

  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets_ids
  subnet_ids = module.vpc.private_subnets_ids

  manage_aws_auth_configmap = true
  # create_aws_auth_configmap = false
  cluster_admin_users = ["melvinkimathi"]
  cluster_admin_roles = []

  create_private_node_group = true
}