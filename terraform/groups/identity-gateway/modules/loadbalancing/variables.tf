variable "service_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpn_cidrs" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(any)
}

variable "target_port" {
  type = number
}

variable "domain_name" {
  type = string
}

variable "create_route53_record" {
  type = bool
}

variable "route53_zone" {
  type = string
}

variable "create_certificate" {
  type = bool
}

variable "certificate_domain" {
  type = string
}