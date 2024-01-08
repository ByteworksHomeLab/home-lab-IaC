terraform {
  backend "s3" {
    bucket         = "byteworksinc-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "homelab-terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }

    dns = {
      source  = "hashicorp/dns"
      version = "3.4.0"
    }

    lxd = {
      source = "terraform-lxd/lxd"
      version = "1.10.4"
    }

#    acme = {
#      source  = "vancluever/acme"
#      version = "~> 2.5.3"
#    }
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "dns" {
  update {
    server        = "10.0.0.8"
    key_name      = "tsig-key."
    key_algorithm = "hmac-sha256"
    key_secret    = var.tsig_key
  }
}

# https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs
provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  lxd_remote {
    name     = "lxd-athena"
    scheme   = "https"
    address  = "10.0.0.4"
    password = var.lxd_password
    default  = true
  }

}

#provider "acme" {
#  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
##  server_url = "https://acme-v02.api.letsencrypt.org/directory"
#}


