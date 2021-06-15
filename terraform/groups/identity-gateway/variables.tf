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

variable "application_url" {
  type        = string
  description = "Application URL that IG will be in front of"
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

variable "oidc_client_id" {
  type        = string
  description = "ForgeRock Identity Cloud client ID"
  default     = "oidc_client"
}

variable "oidc_client_secret" {
  type        = string
  description = "Client secret for the above client"
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
