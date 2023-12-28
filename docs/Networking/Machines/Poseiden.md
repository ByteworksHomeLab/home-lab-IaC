# Poseiden

```shell
ip a show

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether dc:a6:32:d4:48:de brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.2/24 brd 192.168.3.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::dea6:32ff:fed4:48de/64 scope link
       valid_lft forever preferred_lft forever
```

```
sudo chmod 600 /etc/netplan/50-cloud-init.yaml
sudo apt-get install openvswitch-switch
```

Update `/etc/netplan/50-cloud-init.yaml`.

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      dhcp4: false
      dhcp6: false
      interfaces: [ eth0 ]
      macaddress: dc:a6:32:d4:48:de
      addresses: [192.168.3.2/24]
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
    link/ether a0:d3:c1:1a:c8:81 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.7/24 brd 192.168.3.255 scope global br0
       valid_lft forever preferred_lft forever
    inet6 fe80::a2d3:c1ff:fe1a:c881/64 scope link
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
