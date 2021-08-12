variable "service_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "internal" {
  type = bool
}

variable "ingress_cidr_blocks" {
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

variable "tags" {
  type = object({
    Environment    = string
    Service        = string
    ServiceSubType = string
    Team           = string
  })
}
