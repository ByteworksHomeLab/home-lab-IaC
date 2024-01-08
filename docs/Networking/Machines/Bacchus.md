# Bacchus

```shell
$ ip a show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 2c:44:fd:19:81:d1 brd ff:ff:ff:ff:ff:ff
    altname enp0s25
    inet 10.0.0.5/16 brd 10.0.255.255 scope global eno1
       valid_lft forever preferred_lft forever
    inet6 fe80::2e44:fdff:fe19:81d1/64 scope link
       valid_lft forever preferred_lft forever
3: enp1s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 2c:44:fd:19:81:d2 brd ff:ff:ff:ff:ff:ff
```

```
sudo chmod 600 /etc/netplan/00-installer-config.yaml
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
      dhcp6: false
      dhcp4: true
      activation-mode: manual
  bridges:
    br0:
      dhcp4: false
      dhcp6: false
      interfaces: [ eno1 ]
      macaddress: 2c:44:fd:19:81:d1
      addresses: [10.0.0.5/16]
      nameservers:
        addresses:
        - 10.0.0.8
        - 10.0.0.9
        - 10.0.0.1
        search: [byteworksinc.com]
      routes:
        - to: default
          via: 10.0.0.1
      mtu: 1500
      parameters:
        stp: true
        forward-delay: 4
```

```shell
sudo netplan generate
sudo netplan apply
```

Check the results:

```shell
ip a show

3: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 2c:44:fd:19:81:d2 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::2e44:fdff:fe19:81d2/64 scope link
       valid_lft forever preferred_lft forever
4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 2c:44:fd:19:81:d1 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.5/16
 brd 10.0.0.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::2e44:fdff:fe19:81d1/64 scope link
``` 
