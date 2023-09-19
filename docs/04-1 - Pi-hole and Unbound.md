
# Pi-hole Installation

https://patrickdomingues.com/2023/07/09/how-to-install-pi-hole-on-ubuntu-22-04-step-by-step-guide/

```shell
sudo apt update && sudo apt upgrade -y
curl -sSL https://install.pi-hole.net | bash
```

Follow the on-screen prompts. Record the admin password when the installation is complete.

```shell
sudo ufw status
sudo ufw allow 80
sudo ufw allow 22
sudo ufw allow 53
sudo ufw enable
```

Check the work at http://${host name}/admin using the password from the installation.

```shell
ifconfig -a | grep -oP '^\w+(?=: flags)'
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

# Pi-Hold with Unifi Server Gateway

https://docs.pi-hole.net/routers/ubiquiti-usg/

Pi-hold network information:

```shell
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.8  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::dea6:32ff:fee6:20df  prefixlen 64  scopeid 0x20<link>
        ether dc:a6:32:e6:20:df  txqueuelen 1000  (Ethernet)
        RX packets 70062  bytes 48156511 (48.1 MB)
        RX errors 0  dropped 7012  overruns 0  frame 0
        TX packets 27351  bytes 7221726 (7.2 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Unifi Service Gateway --> Network --> {default} --> Settings --> DHCP DNS was set with the information above.

## Pi-hole + unbound

https://docs.pi-hole.net/guides/dns/unbound/
