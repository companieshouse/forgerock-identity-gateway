locals {
  common_tags = {
    Environment    = var.environment
    Service        = "ch-account"
    ServiceSubType = var.service_name
    Team           = "amido"
  }
  public_allow_cidr_blocks = [
    "194.75.36.0/24",
    "62.254.241.64/26",
    "5.148.32.192/26",
    "5.148.69.16/28",
    "31.221.110.80/29",
    "154.51.64.64/27",
    "154.51.128.224/27",
    "167.98.1.160/28",
    "167.98.25.176/28",
    "167.98.200.192/27",
    "195.95.131.0/24"
  ]

  ingress_cidr_blocks = var.internal_access_only ? concat(values(data.vault_generic_secret.internal_cidrs.data), var.internal_access_cidrs) : local.public_allow_cidr_blocks
  subnet_ids          = var.internal_access_only ? data.aws_subnet_ids.data_subnets.ids : data.aws_subnet_ids.public_subnets.ids

}
