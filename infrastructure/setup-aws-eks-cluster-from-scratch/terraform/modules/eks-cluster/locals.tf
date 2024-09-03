locals {
  env_prefix = var.cluster_name
  vpc_id = var.vpc_id

  # TODO: pass the SG id dynamically
  # alb_secutity_group_id = ""
  # alb_secutity_group_id = try(module.vpc.aws_security_group.alb_sg[0].id, null)
  private_subnet_ids = var.private_subnet_ids
  subnet_ids = []

  private_node_group_ami_id = data.aws_ami.eks_default.image_id
  private_node_group_ami_type = "AL2_x86_64"

  tags = merge(
    var.tags,
    {
      Name = upper(local.env_prefix)
    }
  )

  create_iam_role = false
  admin_users = var.cluster_admin_users
  admin_roles = var.cluster_admin_roles
  admin_users_arns = [for u in data.aws_iam_user.users : u.arn]
  admin_roles_arns = [for r in var.cluster_admin_roles : r.rolearn]

  cluster_admin_role_arns = local.create_iam_role ? local.admin_roles_arns : [var.cluster_admin_iam_role_arn]
  kms_key_administrators = concat(local.cluster_admin_role_arns, local.admin_users_arns)

  created_auth_role = {
    rolearn  = module.eks_admins_iam_role.iam_role_arn
    username = module.eks_admins_iam_role.iam_role_name
    groups   = ["system:masters"]
  }
}