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

variable "application_ip" {
  type = string
}
