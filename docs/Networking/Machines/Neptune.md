# Neptune

```shell
ip a show

2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether b8:85:84:9d:ee:56 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.3/24 brd 192.168.3.255 scope global enp1s0
       valid_lft forever preferred_lft forever
    inet6 fe80::ba85:84ff:fe9d:ee56/64 scope link
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
    enp1s0:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      dhcp4: false
      dhcp6: false
      interfaces: [ enp1s0 ]
      macaddress: b8:85:84:9d:ee:56
      addresses: [192.168.3.3/24]
      nameservers:
        addresses: [192.168.3.2, 8.8.8.8]
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

4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether b8:85:84:9d:ee:56 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.3/24 brd 192.168.3.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::ba85:84ff:fe9d:ee56/64 scope link
       valid_lft forever preferred_lft forever
```

## Remove virbr0 from all machines

```shell
sudo virsh
net-destroy default
net-undefine default
exit
```

## Add the bridge to KVM

Create file `br0.xml.`
Create a file `br0.xml` in the home directory

```xml
<network>
    <name>br0</name>
    <forward mode="bridge"/>
    <bridge name="br0"/>
</network>
```

The following on all machines:

```shell
sudo virsh
net-define /home/stevemitchell/br0.xml
net-start br0
net-autostart br0
net-list
exit
```
