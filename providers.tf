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
      version = "3.3.2"
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
    server        = "192.168.3.7"
    key_name      = "tsig-key."
    key_algorithm = "hmac-sha256"
    key_secret    = var.tsig_key
  }
}

#provider "acme" {
#  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
##  server_url = "https://acme-v02.api.letsencrypt.org/directory"
#}


