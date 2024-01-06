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
