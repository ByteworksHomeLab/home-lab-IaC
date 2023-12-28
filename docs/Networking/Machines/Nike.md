# Nike
```shell
ip a show

2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 64:51:06:4c:ba:16 brd ff:ff:ff:ff:ff:ff
    altname enp0s25
    inet 192.168.3.6/24 brd 192.168.3.255 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::6651:6ff:fe4c:ba16/64 scope link
       valid_lft forever preferred_lft forever
```

```
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo apt-get install openvswitch-switch -y
```

Update `/etc/netplan/00-installer-config.yaml`.

```yaml
network:
  version: 2
  ethernets:
    eno1:
      dhcp4: false
      dhcp6: false
    enp1s0:
      dhcp4: true
      optional: true
  bridges:
    br0:
      dhcp4: false
      dhcp6: false
      interfaces: [ eno1 ]
      macaddress: 64:51:06:4c:ba:16
      addresses: [192.168.3.6/24]
      nameservers:
         addresses: 
           - 8.8.8.8
           - 1.1.1.1
         search: [byteworksinc.com]
      routes:
         - to: default
           via: 192.168.3.1
      mtu: 1500
      parameters:
        stp: true
        forward-delay: 4
```

```shell
sudo netplan generate
sudo netplan apply
```

```shell
ip a show

5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 64:51:06:4c:ba:16 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.6/24 brd 192.168.3.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::6651:6ff:fe4c:ba16/64 scope link
       valid_lft forever preferred_lft forever
```
