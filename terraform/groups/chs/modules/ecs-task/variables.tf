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
  type = list(string)
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

variable "lb_security_group_ids" {
  type = list(string)
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

variable "target_group_arns" {
  type = list(string)
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

variable "api_load_balancer" {
  type = string
}

variable "fidc_fqdn" {
  type = string
}

variable "fidc_realm" {
  type = string
}

variable "agent_secret_id" {
  type = string
}