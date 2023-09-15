resource "dns_a_record_set" "athena" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.1.9"]
  name      = "artemis"
  ttl       = 300
}

resource "dns_a_record_set" "hermes" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.1.10"]
  name      = "hermes"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "bacchus" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.1.11"]
  name      = "bacchus"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "nike" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.1.12"]
  name      = "nike"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "zeus" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.1.12"]
  name      = "zeus"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "nas1" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.1.5"]
  name      = "nas1"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}
