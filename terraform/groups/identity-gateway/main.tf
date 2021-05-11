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
}

module "webfiling" {
  source                  = "./modules/ecs-task"
  region                  = var.region
  service_name            = "webfiling"
  vpc_id                  = data.aws_vpc.vpc.id
  subnet_ids              = data.aws_subnet_ids.data_subnets.ids
  ecs_cluster_id          = module.ecs.cluster_id
  ecs_task_role_arn       = module.ecs.task_role_arn
  lb_security_group_id    = module.webfiling_lb.security_group_id
  container_image_version = var.container_image_version
  ecr_url                 = var.ecr_url
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  log_group_name          = "forgerock-monitoring"
  log_prefix              = "webfiling-ig"
  target_group_arn        = module.webfiling_lb.target_group_arn
  application_host        = var.application_host
  application_ip        = var.application_ip
}
