# DNS

Follow these instructions: 

* [Ubuntu 22-04 Domain Name Service (DNS)](https://ubuntu.com/server/docs/service-domain-name-service-dns)

Security:

See these articles:
* https://aaronsplace.co.uk/blog/2021-08-15-terraform-and-dynamic-dns-updates.html

```shell
sudo mkdir -p /etc/bind/tsig
cd /etc/bind/tsig
```

Create a verify a tsig key

```shell
tsig-keygen -a hmac-sha256
key "tsig-key" {
	algorithm hmac-sha256;
	secret "tsa8U9VeFLA8slMgUpACX7Z66i/K5zSCzhuli/hu9aY=";
};

Create the key file, `/etc/bind/tsig/tsig.key`, and add the output from above.

```shell
sudo vi /etc/bind/tsig/tsig.key
```

Include the tsig key in the named.conf.

```shell
sudo vi /etc/bind/named.conf
```
Include the file:

```text
include "/etc/bind/tsig.key";
```
Check your work:

```shell
  sudo named-checkzone byteworksinc.com /etc/bind/db.byteworksinc.com
  sudo named-checkzone 192.in-addr.arpa /etc/bind/db.192
  sudo named-checkconf
  sudo systemctl restart bind9.service
```


Add the secret value to the `terraform-tfvars` file.

# AppArmor

Be see to update AppArmor

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
https://documentation.ubuntu.com/lxd/en/latest/remotes/

https://cloud-images.ubuntu.com/releases/

lxc image list ubuntu: 22.04

lxc image list images:


