locals {
  common_tags = {
    Environment    = var.environment
    Service        = "ch-account"
    ServiceSubType = var.service_name
    Team           = "amido"
  }
  test_cidr_blocks = var.test_access_enable ? jsondecode(data.vault_generic_secret.test_cidrs.data["cidrs"]) : []

  ingress_cidr_blocks = var.internal_access_only ? concat(values(data.vault_generic_secret.internal_cidrs.data), var.internal_access_cidrs, local.test_cidr_blocks) : concat(jsondecode(data.vault_generic_secret.external_cidrs.data["external_cidrs"]), var.internal_access_cidrs)
  subnet_ids          = var.internal_access_only ? data.aws_subnets.application_subnets.ids : data.aws_subnets.public_subnets.ids

  iboss_cidr_blocks = jsondecode(data.vault_generic_secret.iboss_cidrs.data_json)

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  elb_access_logs_prefix      = "elb-access-logs"
  elb_access_logs_bucket_name = local.security_s3_data["elb-access-logs-bucket-name"]
}
