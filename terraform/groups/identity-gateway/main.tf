###
# Data lookups
###
data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "data_subnets" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["*-applications-*"]
  }
}

###
# Modules
###
module "ecs" {
  source       = "./modules/ecs"
  service_name = var.service_name
  vpc_id       = data.aws_vpc.vpc.id
  tags         = local.common_tags
}

module "webfiling_lb" {
  source                = "./modules/loadbalancing"
  service_name          = "forgerock-ig-webfiling"
  vpc_id                = data.aws_vpc.vpc.id
  vpn_cidrs             = values(data.terraform_remote_state.networking.outputs.vpn_cidrs)
  subnet_ids            = data.aws_subnet_ids.data_subnets.ids
  target_port           = 8080
  domain_name           = var.domain_name
  create_route53_record = var.create_route53_record
  route53_zone          = var.route53_zone
  create_certificate    = var.create_certificate
  certificate_domain    = var.certificate_domain
  tags                  = local.common_tags
}

module "webfiling" {
  source                         = "./modules/ecs-task"
  region                         = var.region
  service_name                   = "webfiling"
  vpc_id                         = data.aws_vpc.vpc.id
  subnet_ids                     = data.aws_subnet_ids.data_subnets.ids
  ecs_cluster_id                 = module.ecs.cluster_id
  ecs_task_role_arn              = module.ecs.task_role_arn
  lb_security_group_id           = module.webfiling_lb.security_group_id
  container_image_version        = var.container_image_version
  ecr_url                        = var.ecr_url
  task_cpu                       = var.task_cpu
  task_memory                    = var.task_memory
  log_group_name                 = "forgerock-monitoring"
  log_prefix                     = "webfiling-ig"
  target_group_arn               = module.webfiling_lb.target_group_arn
  application_host               = replace(var.application_url, "https://", "")
  fidc_fqdn                      = replace(var.fidc_custom_url, "https://", "")
  fidc_realm                     = var.fidc_realm
  fidc_login_journey             = var.fidc_login_journey
  oidc_client_id                 = var.oidc_client_id
  oidc_client_secret             = var.oidc_client_secret
  ui_login_url                   = var.ui_login_url
  application_legacy_host        = var.application_legacy_host
  application_legacy_host_prefix = var.application_legacy_host_prefix
  application_host_prefix        = var.application_host_prefix
  autoscaling_min                = var.autoscaling_min
  autoscaling_max                = var.autoscaling_max
  target_cpu                     = var.target_cpu
  target_memory                  = var.target_memory
  tags                           = local.common_tags
}
