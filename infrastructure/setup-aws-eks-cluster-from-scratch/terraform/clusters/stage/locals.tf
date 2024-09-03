locals {
  env_prefix = "stage"
  alb_tags = {}
  tags = {}

  vpc_id = module.vpc.vpc_id

  # use_exec = lower(var.use_role_to_login) == "yes"
  auth_token = try(data.aws_eks_cluster_auth.default[0].token, null)
  exec_args  = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name, "--profile", var.profile, "--role-arn", module.cluster.eks_admin_role]
}