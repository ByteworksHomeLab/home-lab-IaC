#resource "lxd_instance" "container1" {
#  name      = "container1"
#  image     = "images:ubuntu/22.04"
#  ephemeral = false
#
#  config = {
#    "boot.autostart" = true
#  }
#
#  limits = {
#    cpu = 2
#  }
#
#  profiles = ["k8s"]
#}
