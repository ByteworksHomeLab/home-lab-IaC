resource "dns_a_record_set" "poseiden" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.2"]
  name      = "poseiden"
  ttl       = 300
}

resource "dns_a_record_set" "neptune" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.3"]
  name      = "neptune"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "athena" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.4"]
  name      = "athena"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "bacchus" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.5"]
  name      = "bacchus"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "nike" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.6"]
  name      = "nike"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "zeus" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.7"]
  name      = "zeus"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

resource "dns_a_record_set" "haproxy1" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.8"]
  name      = "haproxy1"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}


resource "dns_a_record_set" "haproxy2" {
  zone      = "byteworksinc.com."
  addresses = ["192.168.3.9"]
  name      = "haproxy2"
  #  Default is 1 hour, but since this is a home lab, we want less
  ttl       = 300
}

