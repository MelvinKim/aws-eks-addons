# variable "use_role_to_login" {
#   description = "Use 'yes' to enable exec block or 'no' to disable it. If you are creating the cluster for the first time set this to 'no'."
#   type        = string
# }

variable "region" {
  default = "us-west-2"
}

variable "main_aws_profile" {
  default = "jeffrey-account"
}

variable "profile" {
  default = "jeffrey-account"
}

variable "vpc_id" {
  default = "vpc-052d2861197487268"
}

variable "cluster_name" {
  default = "stage-cluster-cluster"
}