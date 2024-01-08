resource "dns_a_record_set" "poseiden" {
  zone = "byteworksinc.com."
  name = "poseiden"
  addresses = [
    "10.0.0.2",
  ]
  ttl = 300
}
resource "dns_a_record_set" "neptune" {
  zone = "byteworksinc.com."
  name = "neptune"
  addresses = [
    "10.0.0.4",
  ]
  ttl = 300
}
resource "dns_a_record_set" "bacchus" {
  zone = "byteworksinc.com."
  name = "bacchus"
  addresses = [
    "10.0.0.5",
  ]
  ttl = 300
}
resource "dns_a_record_set" "nike" {
  zone = "byteworksinc.com."
  name = "nike"
  addresses = [
    "10.0.0.6",
  ]
  ttl = 300
}
resource "dns_a_record_set" "zeus" {
  zone = "byteworksinc.com."
  name = "zeus"
  addresses = [
    "10.0.0.7",
  ]
  ttl = 300
}

resource "dns_a_record_set" "nas" {
  zone = "byteworksinc.com."
  name = "nas"
  addresses = [
    "10.0.0.10",
  ]
  ttl = 300
}

#resource "dns_a_record_set" "cluster-mgmt" {
#  zone = "byteworksinc.com."
#  name = "cluster-mgmt"
#  addresses = [
#    "10.0.0.66",
#  ]
#  ttl = 300
#}
