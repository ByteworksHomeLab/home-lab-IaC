
# ldap and bind
resource "dns_a_record_set" "poseiden" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.2"]
  name      = "poseiden"
  ttl       = 300
}

# KVM Host (with KeyCloak and HAProxy)
resource "dns_a_record_set" "neptune" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.3"]
  name      = "neptune"
  ttl       = 300
}

# KVM Host (HAProxy and SonarQube)
resource "dns_a_record_set" "athena" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.4"]
  name      = "athena"
  ttl       = 300
}

# KVM Host (Kubernetes)
resource "dns_a_record_set" "bacchus" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.5"]
  name      = "bacchus"
  ttl       = 300
}

# KVM Host (Kubernetes)
resource "dns_a_record_set" "nike" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.6"]
  name      = "nike"
  ttl       = 300
}
# KVM Host (Kubernetes)
resource "dns_a_record_set" "zeus" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.7"]
  name      = "zeus"
  ttl       = 300
}

resource "dns_a_record_set" "haproxy1" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.8"]
  name      = "haproxy1"
  ttl       = 300
}


resource "dns_a_record_set" "haproxy2" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.9"]
  name      = "haproxy2"
  ttl       = 300
}

