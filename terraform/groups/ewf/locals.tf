locals {
  common_tags = {
    Environment    = var.environment
    Service        = "ch-account"
    ServiceSubType = var.service_name
    Team           = "amido"
  }

  ingress_cidr_blocks = var.internal_access_only ? concat(values(data.vault_generic_secret.internal_cidrs.data), var.internal_access_cidrs) : concat(jsondecode(data.vault_generic_secret.external_cidrs.data["external_cidrs"]), var.internal_access_cidrs)
  subnet_ids          = var.internal_access_only ? data.aws_subnet_ids.data_subnets.ids : data.aws_subnet_ids.public_subnets.ids

}
