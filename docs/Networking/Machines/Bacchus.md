# Bacchus

```shell
ip a show

2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether 2c:44:fd:19:81:d1 brd ff:ff:ff:ff:ff:ff
       altname enp0s25
       inet 192.168.3.5/24 brd 192.168.3.255 scope global eno1
          valid_lft forever preferred_lft forever
       inet6 fe80::2e44:fdff:fe19:81d1/64 scope link
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
      macaddress: 2c:44:fd:19:81:d1
      addresses: [192.168.3.5/24]
      nameservers:
        addresses: [192.168.3.2]
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

Check the results:

```shell
ip a

5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 2c:44:fd:19:81:d1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.5/24 brd 192.168.3.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::2e44:fdff:fe19:81d1/64 scope link
       valid_lft forever preferred_lft forever
```
