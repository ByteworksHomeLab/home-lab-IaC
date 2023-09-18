
```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.3.7
```

```shell
sudo hostnamectl set-hostname ns1 --static

sudo vi /etc/hosts
```

Etc Hosts

```text
127.0.0.1 localhost.localdomain localhost
192.168.3.7 ns1.byteworksinc.com ns1

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
```
