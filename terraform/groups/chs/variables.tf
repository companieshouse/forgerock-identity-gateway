variable "vault_username" {
  type        = string
  description = "Username for connecting to Vault"
}

variable "vault_password" {
  type        = string
  description = "Password for connecting to Vault"
}

variable "region" {
  type        = string
  description = "AWS region for deployment"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC to be used for AWS resources"
}

variable "service_name" {
  type        = string
  description = "The service name to be used when creating AWS resources"
  default     = "forgerock-identity-gateway"
}

variable "ecr_url" {
  type = string
}

variable "container_image_version" {
  type        = string
  description = "Version of the docker image to deploy"
  default     = "latest"
}

variable "task_cpu" {
  type        = number
  description = "The cpu unit limit for the ECS task"
}
variable "task_memory" {
  type        = number
  description = "The memory limit for the ECS task"
}

variable "route53_zone" {
  type        = string
  description = "The Route53 hosted zone to use for DNS records"
  default     = "N/A"
}

variable "create_route53_record" {
  type        = bool
  description = "Should a Route53 record be created"
}

variable "domain_name" {
  type        = string
  description = "The domain name to use for the application"
}

variable "create_certificate" {
  type        = bool
  description = "Should a Amazon SSL certificate be created"
}

variable "certificate_domain" {
  type        = string
  description = "The domain used to look up existing certificates"
  default     = "N/A"
}

variable "autoscaling_min" {
  type        = number
  description = "Minimum number of IG instances"
}

variable "autoscaling_max" {
  type        = number
  description = "Maximum number of IG instances"
}

variable "target_cpu" {
  type        = number
  description = "Autoscaling: Target CPU usage percentage"
}

variable "target_memory" {
  type        = number
  description = "Autoscaling: Target Memory usage percentage"
}

variable "api_load_balancer" {
  type = string
}

variable "create_external_lb" {
  type    = bool
  default = false
}

variable "fidc_custom_url" {
  type        = string
  description = "Custom URL for ForgeRock Identity Cloud"
}

variable "fidc_realm" {
  type        = string
  description = "ForgeRock Identity Cloud Realm"
  default     = "alpha"
}

variable "agent_secret_id" {
  type        = string
  description = "Identity Gateway Agent Secret ID"
}

variable "ig_jvm_args" {
  type        = string
  description = "Flags for IG JVM"
}

variable "root_log_level" {
  type        = string
}

variable "alerting_email_address" {
  type = string
}
