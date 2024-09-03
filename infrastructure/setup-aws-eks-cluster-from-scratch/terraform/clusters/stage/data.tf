data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    Name = "*ublic*"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    Name = "*rivate*"
  }
}

data "aws_eks_clusters" "clusters" {}

data "aws_eks_cluster" "default" {
  count = contains(try(data.aws_eks_clusters.clusters.names), module.cluster.cluster_name) ? 1 : 0
  name  = module.cluster.cluster_name
  depends_on = [ module.cluster ]
}

data "aws_eks_cluster_auth" "default" {
  count = contains(try(data.aws_eks_clusters.clusters.names), module.cluster.cluster_name) ? 1 : 0
  name  = module.cluster.cluster_name
  depends_on = [ module.cluster ]
}
