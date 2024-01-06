# Poseiden

```shell
$ ip a show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether d8:9e:f3:89:1d:ca brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.2/24 brd 192.168.3.255 scope global enp2s0
       valid_lft forever preferred_lft forever
    inet6 fe80::da9e:f3ff:fe89:1dca/64 scope link
       valid_lft forever preferred_lft forever
```

```
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo apt-get install openvswitch-switch
```

Update `/etc/netplan/00-installer-config.yaml`.

```yaml
network:
  version: 2
  ethernets:
    enp2s0:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      dhcp4: false
      dhcp6: false
      interfaces: [ enp2s0 ]
      macaddress: d8:9e:f3:89:1d:ca
      addresses: [192.168.3.2/24]
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
