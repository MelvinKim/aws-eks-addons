data "aws_caller_identity" "current" {}

data "aws_iam_user" "users" {
    for_each = toset(local.admin_users)
    user_name = each.value
}

data "aws_vpc" "cluster_vpc" {
    id = local.vpc_id
}

data "aws_security_group" "alb_security_group_id" {
    id = aws_security_group.efs_mount_sg.id
}

data "aws_ami" "eks_default" {
    most_recent = true
    owners = ["amazon"]

    filter {
      name = "name"
      values = ["amazon-eks-node-${var.cluster_version}-v*"]
    }
}