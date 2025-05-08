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

variable "ecs_cluster_name" {
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

variable "ig_host" {
  type = string
}

variable "fidc_fqdn" {
  type = string
}

variable "fidc_realm" {
  type = string
}

variable "fidc_main_journey" {
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

variable "ui_url" {
  type = string
}

variable "login_path" {
  type = string
}

variable "logout_path" {
  type = string
}

variable "error_path" {
  type = string
}

variable "manage_path" {
  type = string
}

variable "companies_path" {
  type = string
}

variable "webfiling_comp" {
  type = string
}

variable "application_legacy_host" {
  type = string
}

variable "application_legacy_host_prefix" {
  type = string
}

variable "application_beta_host" {
  type = string
}

variable "application_beta_host_prefix" {
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

variable "autoscaling_min" {
  type = number
}

variable "autoscaling_max" {
  type = number
}

variable "target_cpu" {
  type = number
}

variable "target_memory" {
  type = number
}

variable "ig_jvm_args" {
  type = string
  description = "Flags for IG JVM"
}

variable "root_log_level" {
  type = string
}

variable "alerting_email_address" {
  type = string
}
