# DNS

See the Kubenetes README for an explanation of how to create the k8s-leader profile.

```shell
lxc launch images:ubuntu/22.04 ns1 --profile k8s-leader
```
# AppArmor

To enable access to AppArmor you need to edit the lxc conf:

```shell
lxc stop ns1
lxc config edit ns1
```
Add the blocks below labeled limits, linux, and raw.lxc, save your changes, then stop and start the ns1 container the restart it.

```shell
architecture: x86_64
config:
  image.architecture: amd64
  image.description: Ubuntu jammy amd64 (20240107_07:42)
  image.os: Ubuntu
  image.release: jammy
  image.serial: "20240107_07:42"
  image.type: squashfs
  image.variant: default
  limits.cpu: "2"
  limits.memory: 4GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter
  security.nesting: "true"
  security.privileged: "true"
  raw.lxc: |-
    lxc.apparmor.profile=unconfined
    lxc.cap.drop=
  volatile.base_image: 1db9928f24183af66f45734f29d12f36062e2ddd7f3c00dbf25acccea76cc4e8
  volatile.cloud-init.instance-id: 96a15a3a-7742-41a4-b661-883e3c87e8e9
  volatile.eth0.hwaddr: 00:16:3e:6b:96:a7
  volatile.idmap.base: "0"
  volatile.idmap.current: '[]'
  volatile.idmap.next: '[]'
  volatile.last_state.idmap: '[]'
  volatile.last_state.power: STOPPED
  volatile.uuid: dba79b42-fc28-4d59-858c-341ef5bd3fa4
devices: {}
ephemeral: false
profiles:
- k8s-leader
stateful: false
```

Change the IP address:

```shell
vim /etc/netplan/10-lxc.yaml
```
Replace the file contents with this.

```shell
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
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

Follow these instructions: 

* [Ubuntu 22-04 Domain Name Service (DNS)](https://ubuntu.com/server/docs/service-domain-name-service-dns)

```shell
apt update
apt install bind9 dnsutils -y
```

Edit `named.conf.local` 

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


