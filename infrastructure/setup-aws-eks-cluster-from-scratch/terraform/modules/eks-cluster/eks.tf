module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name = "${local.env_prefix}-cluster"
  cluster_version = "1.30"
  cluster_endpoint_private_access = var.endpoint_private_access
  cluster_endpoint_public_access = var.endpoint_public_access

  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa = var.enable_irsa

  cluster_addons = {
    # extensible DNS server that can serve as the Kubernetes cluster DNS.
    coredns = {
      most_recent = true
      preserve = true
      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    # maintains network rules on each Amazon EC2 node. It enables network communication to your Pods.
    kube-proxy = {
      most_recent = true
      preserve = true
    }
    # a Kubernetes container network interface (CNI) plugin that provides native VPC networking for your cluster.
    vpc-cni = {
      most_recent = true
      preserve = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      preserve = true
    }

    aws-efs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      preserve = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    disk_size = var.cluster_instance_disk_size
    attach_cluster_primary_security_group = true
    # vpc_security_group_ids = []
    iam_role_additional_policies = {
      ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      cloudwatch = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    }
  }
  eks_managed_node_groups = {
    private = {
      create = var.create_private_node_group
      name = upper("${local.env_prefix}-private")
      use_name_prefix = false
      description = "EKS managed private node group launch template"

      # launch_template_name = upper("${local.env_prefix}-private-lt")
      # launch_template_use_name_prefix = false
      # create_launch_template = var.private_node_group.create_launch_template
      # use_custom_launch_template = var.private_node_group.create_launch_template

      # ami_id = local.private_node_group_ami_id
      # ami_type = local.private_node_group_ami_type

      ebs_optimized = true
      block_device_mappings = [
        {
          device_name = var.private_node_group.device_name
          ebs = {
            volume_size = coalesce(var.private_node_group.disk_size, var.cluster_instance_disk_size)
            delete_on_termination = true
            volume_type = "gp3"
          }
        }
      ]

      desired_size = coalesce(var.private_node_group.desired_size, 1)
      min_size = coalesce(var.private_node_group.min_size, var.cluster_min_size)
      max_size = coalesce(var.private_node_group.max_size, var.cluster_max_size)
      instance_types = coalesce(var.private_node_group.instance_types, var.cluster_instance_types)
      capacity_type = "SPOT" # ON_DEMAND, Try spot

      subnet_ids = local.private_subnet_ids
      network_interfaces = [
        {
          delete_on_termination = true
          device_index = 0
          # If nodes are provisioned in private subnets, do not create a public ip for the nodes
          associate_public_ip_address = length(local.private_subnet_ids) > 0 ? false : true
        }
      ]

      taints = concat(var.taints, var.private_node_group.taints)

      tags = local.tags
      launch_template_tags = local.tags

      create_iam_role = true
      iam_role_name = upper("${local.env_prefix}-private-ng-role")
      iam_role_use_name_prefix = false
      iam_role_description = "EKS managed private node group"
    }
  }

  cluster_enabled_log_types = var.cluster_enabled_log_types

  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  create_aws_auth_configmap = var.create_aws_auth_configmap
  aws_auth_accounts = [data.aws_caller_identity.current.account_id]
  aws_auth_users = []
  aws_auth_roles = concat(local.create_iam_role ? [local.created_auth_role] : [], local.admin_roles )
  iam_role_name = upper("${local.env_prefix}-role")

  cloudwatch_log_group_retention_in_days = 7

  create_kms_key = true
  # kms_key_administrators = local.kms_key_administrators

  cluster_security_group_additional_rules = {}
  cluster_security_group_name = upper("${local.env_prefix}-sg")
  node_security_group_name = upper("${local.env_prefix}-node-sg")
  node_security_group_tags = {
    "kubernetes.io/cluster/${upper(local.env_prefix)}" = null
  }
  node_security_group_additional_rules = {
    ingress_lb_security_group_id = {
      description = "Allow access from application load balancer to node group for default kubernetes nodeport range"
      protocol = "tcp"
      from_port = 30000
      to_port = 32767
      type = "ingress"
      source_security_group_id = aws_security_group.efs_mount_sg.id
    }
  }
}