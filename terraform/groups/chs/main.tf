###
# Data lookups
###
data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet_ids" "application_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["*-applications-*"]
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["*-public-*"]
  }

  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
}

data "vault_generic_secret" "ig_secret" {
  path = "applications/heritage-${var.environment}-eu-west-2/forgerock/ewf/forgerock-identity-gateway"
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

module "internal_lb" {
  source                = "./modules/loadbalancing"
  service_name          = "forgerock-ig-internal"
  internal              = true
  vpc_id                = data.aws_vpc.vpc.id
  ingress_cidr_blocks   = ["0.0.0.0/0"]
  subnet_ids            = data.aws_subnet_ids.application_subnets.ids
  target_port           = 8080
  domain_name           = var.domain_name
  create_route53_record = var.create_route53_record
  route53_zone          = var.route53_zone
  create_certificate    = var.create_certificate
  certificate_domain    = var.certificate_domain
  tags                  = local.common_tags
}

module "external_lb" {
  source                = "./modules/loadbalancing"
  service_name          = "forgerock-ig-external"
  internal              = false
  vpc_id                = data.aws_vpc.vpc.id
  ingress_cidr_blocks   = local.public_allow_cidr_blocks
  subnet_ids            = data.aws_subnet_ids.public_subnets.ids
  target_port           = 8080
  domain_name           = var.domain_name
  create_route53_record = var.create_route53_record
  route53_zone          = var.route53_zone
  create_certificate    = var.create_certificate
  certificate_domain    = var.certificate_domain
  tags                  = local.common_tags
}

module "ig" {
  source                  = "./modules/ecs-task"
  region                  = var.region
  service_name            = "chs"
  vpc_id                  = data.aws_vpc.vpc.id
  subnet_ids              = data.aws_subnet_ids.application_subnets.ids
  ecs_cluster_id          = module.ecs.cluster_id
  ecs_cluster_name        = var.service_name
  ecs_task_role_arn       = module.ecs.task_role_arn
  lb_security_group_ids   = var.create_external_lb ? [module.internal_lb.security_group_id, module.external_lb.security_group_id] : [module.internal_lb.security_group_id]
  container_image_version = var.container_image_version
  ecr_url                 = var.ecr_url
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  log_group_name          = "forgerock-monitoring"
  log_prefix              = "ig"
  target_group_arns       = var.create_external_lb ? [module.internal_lb.target_group_arn, module.external_lb.target_group_arn] : [module.internal_lb.target_group_arn]
  autoscaling_min         = var.autoscaling_min
  autoscaling_max         = var.autoscaling_max
  target_cpu              = var.target_cpu
  target_memory           = var.target_memory
  api_load_balancer       = var.api_load_balancer
  fidc_fqdn               = replace(var.fidc_custom_url, "https://", "")
  fidc_realm              = var.fidc_realm
  agent_secret_id         = var.agent_secret_id
  tags                    = local.common_tags
  ig_jvm_args             = var.ig_jvm_args
  root_log_level          = var.root_log_level
  signing_key_secret      = data.vault_generic_secret.ig_secret.data["signing_key"]
  domain_name             = var.domain_name
  alerting_email_address  = var.alerting_email_address
}
