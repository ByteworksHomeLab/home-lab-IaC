# DNS

Follow these instructions: 

* [How to configure bind as a private network dns server on Ubuntu 22-04](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-22-04)
* [Configure an administrative sudo user, `ubuntu` ](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04)

Security:

See this articles:
* https://aaronsplace.co.uk/blog/2021-08-15-terraform-and-dynamic-dns-updates.html
* https://bind9.readthedocs.io/en/v9.16.20/advanced.html
* https://movingpackets.net/2013/06/10/bind-enabling-tsig-for-zone-transfers/

```shell
sudo mkdir -p /etc/bind/corp/tsig
cd /etc/bind/corp/tsig
```

Verify the output.

```shell
tsig-keygen -a hmac-sha256
key "tsig-key" {
	algorithm hmac-sha256;
	secret "JgmBEVS5dnA4aUGoVeeQOfzfhfwE6cyqmvfgtMMuJUY=";
};

Create the key file, `/etc/bind/tsig/tsig.key`, with the random string at the end of the last line above.

```shell
sudo vi /etc/bind/corp/byteworksinc.com-tsig.key
```

Add the output generated above.

Include the tsig key in the named.conf.

```shell
sudo vi /etc/bind/named.conf
```
Include the file:

```text
include "/etc/bind/corp/byteworksinc.com-tsig.key";
```
Check your work:

```shell
  sudo named-checkzone byteworksinc.com /etc/bind/zones/db.byteworksinc.com
  sudo named-checkzone 168.192.in-addr.arpa /etc/bind/zones/db.192.168
  sudo named-checkconf
  sudo systemctl restart bind9
```


Add the secret value to the `terraform-tfvars` file.
