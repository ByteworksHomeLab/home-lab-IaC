# Zeus

```shell
ip a show

2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether a0:d3:c1:1a:c8:81 brd ff:ff:ff:ff:ff:ff
    altname enp0s25
    inet 192.168.3.7/24 brd 192.168.3.255 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::a2d3:c1ff:fe1a:c881/64 scope link
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
      macaddress: a0:d3:c1:1a:c8:81
      addresses: [192.168.3.7/24]
      nameservers:
         addresses: [192.168.3.8,192.168.3.9]
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
    link/ether a0:d3:c1:1a:c8:81 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.7/24 brd 192.168.3.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::a2d3:c1ff:fe1a:c881/64 scope link
       valid_lft forever preferred_lft forever
```
