# module "alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name = lower("${local.env_prefix}-alb")
#   internal = false
#   load_balancer_type = "application"

#   vpc_id = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets

#   enable_deletion_protection = false
#   idle_timeout = 600

#   security_group_name = "${local.env_prefix}-sg"
#   security_group_ingress_rules = {
#     all_http = {
#       from_port = 80
#       to_port = 80
#       ip_protocol = "tcp"
#       description = "HTTP web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#       redirect = {
#         port = "443"
#         protocol = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#     all_https = {
#       from_port = 443
#       to_port = 443
#       ip_protocol = "tcp"
#       description = "HTTPS web traffic"
#       cidr_ipv4   = "0.0.0.0/0"
#     }
#   }
#   security_group_egress_rules = {
#     all = {
#       from_port = 0
#       to_port = 0
#       ip_protocol = "-1"
#       cidr_ipv4 = "0.0.0.0/0"
#     }
#   }

#   listeners = {
#     ex-http-https-redirect = {
#       port     = 80
#       protocol = "HTTP"
#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#   }

#   # s3 bucket that will be used to store the ALB access logs
#   # access_logs = local.env_prefix

#   tags = merge(
#     {
#         Name = upper("${local.env_prefix}-alb")
#     },
#     var.alb_tags
#   )
# }