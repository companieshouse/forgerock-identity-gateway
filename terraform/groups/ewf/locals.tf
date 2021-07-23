locals {
  common_tags = {
    Environment    = var.environment
    Service        = "ch-account"
    ServiceSubType = var.service_name
    Team           = "amido"
  }
  public_allow_cidr_blocks = [
    "82.199.87.128/26",
    "82.199.90.136/29",
    "82.199.90.160/27",
    "91.212.42.0/24",
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
}