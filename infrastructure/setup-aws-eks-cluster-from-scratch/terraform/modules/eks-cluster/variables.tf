variable "region" {
  description = "AWS region"
  default = "us-west-2"
}

variable "endpoint_private_access" {
  type = bool
  description = "Defines whether the cluster API access mode is set to private."
  default = false
}

variable "endpoint_public_access" {
  type = bool
  description = "Defines whether the cluster API is publicly available."
  default = true
}

variable "vpc_id" {
  type = string
  description = "The VPC id on which the EKS cluster is running."
}

variable "subnet_ids" {
  type = list(string)
  description = "The subnets that will hosts the EKS cluster data plane(worker nodes)."
}

variable "enable_irsa" {
  type = bool
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA."
  default = true
}

variable "cluster_name" {
  type = string
  description = "EKS cluster name."
}

variable "cluster_instance_disk_size" {
  type = number
  description = "Cluster nodes disk size"
  default = 20
}

variable "create_private_node_group" {
  type = bool
  description = "Determines whether to create nodes in private subnets."
}

variable "cluster_min_size" {
  type = number
  description = "The minimum number of nodes in the private node group."
  default = 1
}

variable "cluster_max_size" {
  type = number
  description = "The maximum number of nodes in the private node group."
  default = 1
}

variable "cluster_instance_types" {
  description = "EKS cluster default instance types."
  type        = list(string)
  default     = ["t3a.small"]
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type = list(string)
  default = ["audit", "api", "authenticator"]
}

variable "manage_aws_auth_configmap" {
  type = bool
  description = "Determines whether to manage the aws-auth configmap."
  default = false
}

variable "create_aws_auth_configmap" {
  type = bool
  description = "Determines whether to create the aws-auth configmap."
  default = false
}

variable "private_subnet_ids" {
  type = list(string)
  description = "Private subnets IDs."
}

variable "cluster_admin_users" {
  description = "EKS cluster admin users."
}

variable "cluster_admin_roles" {
  description = "EKS cluster admin roles."
  type = list(any)
  default = []
}

variable "cluster_admin_iam_role_arn" {
  description = "The ARN of IAM role to use to authenticate to the EKS clusters. If non is provided, one is created with the name `clustername-admin-role"
  type = string
  default = null
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type = string
}

variable "trusted_role_arn" {
  type = string
  description = "List of role maps to add to the aws-auth configmap"
  default = null
}

variable "taints" {
  type = list(map(string))
  description = "The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group."
  default = []
}

variable "tags" {
  description = "Tags to associate created resources."
  type = map(string)
  default = {}
}

variable "efs_throughput_mode" {
  description = "Throughput mode for EFS file system."
  type = string
  default = "bursting"
}

variable "private_node_group" {
  description = "Options to configure the private node group"
  type = object({
    min_size                 = optional(number, null)       # Minimum number of instances/nodes
    max_size                 = optional(number, null)       # Maximum number of instances/nodes
    desired_size             = optional(number, null)       # Desired number of instances/nodes
    disk_size                = optional(number, null)       # Disk size in GiB for nodes. Defaults to `20`
    instance_types           = optional(list(string), null) # Instance types to be used in the default node group
    device_name              = optional(string, "/dev/xvda")
    create_launch_template   = optional(bool, true)
    post_bootstrap_user_data = optional(string, "")
    taints                   = optional(list(map(string)), [])
  })
  default = {}
}