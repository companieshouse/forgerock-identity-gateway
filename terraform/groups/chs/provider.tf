terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "vault" {
  auth_login {
    path = "auth/userpass/login/${var.hashicorp_vault_username}"
    parameters = {
      password = var.hashicorp_vault_password
    }
  }
}