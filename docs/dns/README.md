# DNS

See the Kubenetes README for an explanation of how to create the k8s-leader profile.

```shell
lxc launch images:ubuntu/22.04 ns1 --vm -c limits.cpu=2 -c limits.memory=2GiB 
```

Set a static ip with Netplan

```shell
network:
  version: 2
  ethernets:
    enp5s0:
      dhcp4: true
      dhcp6: false
      dhcp-identifier: mac
      addresses: [10.0.0.8/16]
      nameservers:
         addresses:
         - 10.0.0.1
         search: [byteworksinc.com]
      routes:
         - to: default
           via: 10.0.0.1
      mtu: 1500
```
# AppArmor

Follow these instructions: 

* [Ubuntu 22-04 Domain Name Service (DNS)](https://ubuntu.com/server/docs/service-domain-name-service-dns)

```shell
apt update
apt install bind9 dnsutils -y
```

1) Copy the contents of [named.conf.local](primary%2Fnamed.conf.local) into the `/etc/bind/named.conf.local` file on the server.
2) Replace the contents of `/etc/bind/named.conf.options` the server with the contents of [named.conf.options](primary%2Fnamed.conf.options).
3) Create a zones directory, `mkdir /etc/bind/zones`.
4) Add [db.byteworksinc.com](primary%2Fdb.byteworksinc.com) to the `/etc/bind/zones/db.byteworksinc.com` directory.
4) Add [db.10](primary%2Fdb.10) to the `/etc/bind/zones/db.10` directory.


Security:

See these articles:
* https://aaronsplace.co.uk/blog/2021-08-15-terraform-and-dynamic-dns-updates.html

```shell
sudo mkdir -p /etc/bind/tsig
cd /etc/bind/tsig
tsig-keygen -a hmac-sha256 > tsig.key
```
Add the the tsig key in the named.conf.

```shell
vim /etc/bind/named.conf
```
Include the file:

```text
include "/etc/bind/tsig/tsig.key";
```
Check your work:

```shell
  named-checkzone byteworksinc.com /etc/bind/zones/db.byteworksinc.com
  named-checkzone 10.in-addr.arpa /etc/bind/zones/db.10
  named-checkconf
  systemctl restart bind9.service
```


Add the secret value to the `terraform-tfvars` file.

Be sure to update AppArmor

https://stackoverflow.com/questions/76623550/permissions-error-when-creating-an-a-record

Edit `/etc/apparmor.d/usr.sbin.named`
```shell
  # Bind Updates
  /etc/bind/zones/** rw,
```

Then run these commands:
```shell
chown bind:bind -R /etc/bind
setcap 'cap_net_bind_service=+ep' /usr/sbin/named
systemctl restart apparmor
systemctl restart bind9.service
```


