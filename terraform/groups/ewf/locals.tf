locals {
  common_tags = {
    Environment    = var.environment
    Service        = "ch-account"
    ServiceSubType = var.service_name
    Team           = "amido"
  }

  ingress_cidr_blocks = var.internal_access_only ? concat(values(data.vault_generic_secret.internal_cidrs.data), var.internal_access_cidrs) : concat(values(data.vault_generic_secret.external_cidrs.data), var.external_cidrs)
  subnet_ids          = var.internal_access_only ? data.aws_subnet_ids.data_subnets.ids : data.aws_subnet_ids.public_subnets.ids

}
