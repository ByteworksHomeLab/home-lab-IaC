variable "tsig_key" {
  type      = string
  sensitive = true
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_default_region" {
  default = "us-east-2"
}

variable "certs_bucket_name" {
  default = "byteworksinc-ssl-certs"
}

