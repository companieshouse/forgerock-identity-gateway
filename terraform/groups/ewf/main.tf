###
# Modules
###
# module "ecs" {
#   source       = "./modules/ecs"
#   service_name = var.service_name
#   vpc_id       = data.aws_vpc.vpc.id
#   tags         = local.common_tags
# }

# module "lb" {
#   source                      = "./modules/loadbalancing"
#   service_name                = "forgerock-ig"
#   alb_ssl_policy              = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   vpc_id                      = data.aws_vpc.vpc.id
#   internal                    = var.internal_access_only
#   ingress_cidr_blocks         = local.ingress_cidr_blocks
#   subnet_ids                  = local.subnet_ids
#   target_port                 = 8080
#   domain_name                 = var.domain_name
#   create_route53_record       = var.create_route53_record
#   route53_zone                = var.route53_zone
#   create_certificate          = var.create_certificate
#   certificate_domain          = var.certificate_domain
#   elb_access_logs_bucket_name = local.elb_access_logs_bucket_name
#   elb_access_logs_prefix      = local.elb_access_logs_prefix

#   tags = local.common_tags
# }

# module "ig" {
#   source                         = "./modules/ecs-task"
#   region                         = var.region
#   service_name                   = "identity-gateway"
#   vpc_id                         = data.aws_vpc.vpc.id
#   subnet_ids                     = data.aws_subnets.application_subnets.ids
#   ecs_cluster_id                 = module.ecs.cluster_id
#   ecs_cluster_name               = var.service_name
#   ecs_task_role_arn              = module.ecs.task_role_arn
#   lb_security_group_id           = module.lb.security_group_id
#   container_image_version        = var.container_image_version
#   ecr_url                        = var.ecr_url
#   task_cpu                       = var.task_cpu
#   task_memory                    = var.task_memory
#   log_group_name                 = "forgerock-monitoring"
#   log_prefix                     = "ig"
#   target_group_arn               = module.lb.target_group_arn
#   application_host               = replace(var.application_url, "https://", "")
#   ig_host                        = var.domain_name
#   fidc_fqdn                      = replace(var.fidc_custom_url, "https://", "")
#   fidc_realm                     = var.fidc_realm
#   fidc_main_journey              = var.fidc_main_journey
#   fidc_login_journey             = var.fidc_login_journey
#   oidc_client_id                 = var.oidc_client_id
#   oidc_client_secret             = var.oidc_client_secret
#   ui_url                         = var.ui_url
#   login_path                     = var.login_path
#   logout_path                    = var.logout_path
#   error_path                     = var.error_path
#   manage_path                    = var.manage_path
#   companies_path                 = var.companies_path
#   webfiling_comp                 = var.webfiling_comp
#   application_legacy_host        = var.application_legacy_host
#   application_legacy_host_prefix = var.application_legacy_host_prefix
#   application_host_prefix        = var.application_host_prefix
#   autoscaling_min                = var.autoscaling_min
#   autoscaling_max                = var.autoscaling_max
#   target_cpu                     = var.target_cpu
#   target_memory                  = var.target_memory
#   tags                           = local.common_tags
#   ig_jvm_args                    = var.ig_jvm_args
#   root_log_level                 = var.root_log_level
#   alerting_email_address         = var.alerting_email_address
# }

resource "aws_vpc_security_group_ingress_rule" "iboss_80" {
  for_each    = toset(local.iboss_cidr_blocks["iboss_cidrs"])
  description = "added manually - iboss vpn"

  security_group_id = module.lb.security_group_id

  cidr_ipv4   = each.value
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "iboss_443" {
  for_each    = toset(local.iboss_cidr_blocks["iboss_cidrs"])
  description = "added manually - iboss vpn"

  security_group_id = module.lb.security_group_id

  cidr_ipv4   = each.value
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_shared_services_management" {
  count = var.test_access_enable ? 1 : 0

  security_group_id = module.lb.security_group_id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.shared_services_management.id
  description       = "Allow HTTPS from the shared services management prefix list."
}
