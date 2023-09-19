#
#data "aws_route53_zone" "base_domain" {
#  name = "byteworksinc.com"
#}
#
#resource "tls_private_key" "private_key" {
#  algorithm = "RSA"
#}
#
#resource "acme_registration" "registration" {
#  account_key_pem = tls_private_key.private_key.private_key_pem
#  email_address   = "smitchell@byteworksinc.com"
#}
#
#resource "acme_certificate" "certificate" {
#  account_key_pem           = acme_registration.registration.account_key_pem
#  common_name               = data.aws_route53_zone.base_domain.name
#  subject_alternative_names = ["*.${data.aws_route53_zone.base_domain.name}"]
#
#  recursive_nameservers        = ["8.8.8.8:53"]
#
#  dns_challenge {
#    provider = "route53"
#
#    config = {
#      AWS_ACCESS_KEY_ID     = var.aws_access_key
#      AWS_SECRET_ACCESS_KEY = var.aws_secret_key
#      AWS_DEFAULT_REGION    = var.aws_default_region
#    }
#  }
#
#  depends_on = [acme_registration.registration]
#}
#
#resource "aws_s3_bucket_object" "certificate_artifacts_s3_objects" {
#  for_each = toset(["certificate_pem", "issuer_pem", "private_key_pem"])
#  bucket                 = var.certs_bucket_name
#  key                    = "ca_certs/${each.key}"
#  content                = lookup(acme_certificate.certificate, "${each.key}")
#  server_side_encryption = "aws:kms"
#}
#
#
