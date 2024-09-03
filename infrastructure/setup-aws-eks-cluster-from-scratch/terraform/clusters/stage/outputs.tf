output "cluster_name" {
  value = module.cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.cluster.cluster_security_group_id
}

output "cluster_node_security_group_id" {
  value = module.cluster.node_security_group_id
}

output "cluster_admin_role_arn" {
  value = module.cluster.eks_admin_role
}

output "public_subnets" {
  value = data.aws_subnets.public_subnets.ids
}

output "private_subnets" {
  value = data.aws_subnets.private_subnets.ids
}

output "cluster_asg_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.cluster.autoscaling_group_names
}
