module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = upper("${var.cluster_name}-ebs-csi")
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
        provider_arn = module.eks.oidc_provider_arn
        namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {}
}

module "efs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = upper("${var.cluster_name}-efs-csi")
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
        provider_arn = module.eks.oidc_provider_arn
        namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = {}
}

resource "aws_security_group" "efs_mount_sg" {
  name = upper("${local.env_prefix}-efs-sg")
  description = "Allow EKS cluster nodes to access EFS"
  vpc_id = local.vpc_id

  ingress {
    description = "Allow EKS data plane to access NFS"
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    # countercheck this
    cidr_blocks = [data.aws_vpc.cluster_vpc.cidr_block]
  }

  tags = {
    Name = upper("${local.env_prefix}-alb-sg")
  }
}

resource "aws_efs_file_system" "cluster_efs_file_system" {
  creation_token = var.cluster_name # should be unique, used as reference when creating the Elastic File System to ensure idempotent
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  throughput_mode = var.efs_throughput_mode
  tags = merge(
    local.tags,
    {
        Name = upper("${local.env_prefix}-efs")
        Cost = "storage"
    }
  )
}

resource "aws_efs_mount_target" "alpha" {
  count = length(local.subnet_ids)
  file_system_id = aws_efs_file_system.cluster_efs_file_system.id
  subnet_id = local.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_mount_sg.id]
}