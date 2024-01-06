resource "dns_a_record_set" "poseiden" {
  zone = "byteworksinc.com."
  name = "poseiden"
  addresses = [
    "192.168.3.2",
  ]
  ttl = 300
}
resource "dns_a_record_set" "neptune" {
  zone = "byteworksinc.com."
  name = "neptune"
  addresses = [
    "192.168.3.3",
  ]
  ttl = 300
}
resource "dns_a_record_set" "athena" {
  zone = "byteworksinc.com."
  name = "athena"
  addresses = [
    "192.168.3.4",
  ]
  ttl = 300
}
resource "dns_a_record_set" "bacchus" {
  zone = "byteworksinc.com."
  name = "bacchus"
  addresses = [
    "192.168.3.5",
  ]
  ttl = 300
}
resource "dns_a_record_set" "nike" {
  zone = "byteworksinc.com."
  name = "nike"
  addresses = [
    "192.168.3.6",
  ]
  ttl = 300
}
resource "dns_a_record_set" "zeus" {
  zone = "byteworksinc.com."
  name = "zeus"
  addresses = [
    "192.168.3.7",
  ]
  ttl = 300
}

resource "dns_a_record_set" "nas" {
  zone = "byteworksinc.com."
  name = "nas"
  addresses = [
    "192.168.3.10",
  ]
  ttl = 300
}

resource "dns_a_record_set" "cluster-mgmt" {
  zone = "byteworksinc.com."
  name = "cluster-mgmt"
  addresses = [
    "192.168.3.66",
  ]
  ttl = 300
}
