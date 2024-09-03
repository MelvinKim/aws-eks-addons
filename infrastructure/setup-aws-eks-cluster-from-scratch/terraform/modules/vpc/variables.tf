variable "vpc_name" {
  type = string
  description = "VPC name."
}

variable "cluster_name" {
  type = string
  description = "EKS cluster name."
}

variable "vpc_cidr_block" {
  type = string
  description = "VPC range of IP addresses."
  default = "10.0.0.0/16"
}

variable "vpc_availability_zones" {
  type = list(string)
  description = "VPC availability zones."
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets_cidr" {
  type = list(string)
  description = "Private subnets range of IP addresses."
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets_cidr" {
  type = list(string)
  description = "Public subnets range of IP addresses."
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  type = bool
  description = "Determines whether to provision NAT Gateways for each of your private networks."
  default = true
}

variable "single_nat_gateway" {
  type = bool
  description = "Determines whether you want to provision a single shared NAT Gateway across all of your private networks."
  default = true
}

variable "one_nat_gateway_per_az" {
  type = bool
  description = "Determines whether to provision only one NAT Gateway per availability zone."
  default = false
}

variable "enable_dns_hostnames" {
  type = bool
  description = "Determines whether to enable DNS hostnames in the VPC."
  default = true
}

variable "enable_dns_support" {
  type = bool
  description = "Determines whether to enable DNS support in the VPC."
  default = true
}

variable "alb_tags" {
  description = "ALB tags"
}