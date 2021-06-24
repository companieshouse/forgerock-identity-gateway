variable "region" {
  type = string
}

variable "service_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(any)
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "lb_security_group_id" {
  type = string
}

variable "container_image_version" {
  type = string
}

variable "ecr_url" {
  type = string
}

variable "task_cpu" {
  type = number
}

variable "task_memory" {
  type = number
}

variable "log_group_name" {
  type = string
}

variable "log_prefix" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "application_host" {
  type = string
}

variable "fidc_fqdn" {
  type = string
}

variable "fidc_realm" {
  type = string
}

variable "fidc_login_journey" {
  type = string
}

variable "oidc_client_id" {
  type = string
}

variable "oidc_client_secret" {
  type = string
}

variable "ui_login_url" {
  type = string
}

variable "application_legacy_host" {
  type = string
}

variable "application_legacy_host_prefix" {
  type = string
}

variable "application_host_prefix" {
  type = string
}

variable "tags" {
  type = object({
    Environment    = string
    Service        = string
    ServiceSubType = string
    Team           = string
  })
}
