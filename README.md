# Dynamic bind updates

https://stackoverflow.com/questions/76623550/permissions-error-when-creating-an-a-record

```shell
echo /etc/bind/zones/** rw, > /etc/apparmor.d/local/usr.sbin.named
chown bind:bind -R /etc/bind
setcap 'cap_net_bind_service=+ep' /usr/sbin/named
```
https://unix.stackexchange.com/questions/710321/bind9-dynamic-zone-updates-are-denied-by-apparmor-in-debian11

Also https://dnns.no/dynamic-dns-with-bind-and-nsupdate.html

/etc/apparmor.d/user.sbin.named
```text
...
  /etc/bind/** r,
  /etc/bind/pz/* rw,
  /var/lib/bind/** rw,
  /var/lib/bind/ rw,
  /var/cache/bind/** lrw,
  /var/cache/bind/ rw,
```

named.conf
```text
include "/etc/bind/named.conf.key";
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
```

named.conf.key
```text
key "tsig-key" {
	algorithm hmac-sha256;
	secret "********8";
};
```

named.conf.local
```text
include "/etc/bind/zones.rfc1918";
zone "byteworksinc.com" {
    type master;
    file "/etc/bind/pz/db.byteworksinc.com";
    allow-transfer { 192.168.1.8; };
    also-notify { 192.168.1.8; };
    update-policy {
       grant tsig-key zonesub any;
    };
};
```

named.conf.options
```text
options {
	directory "/var/cache/bind";

	forwarders {
	 	8.8.8.8;
		1.1.1.1;
	};

	dnssec-validation auto;
	listen-on-v6 { any; };
};
```

# Storage Pools

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-virtualization-storage_pools-creating-lvm

```shell
sudo hostnamectl set-hostname bacchus.byteworksinc.com --static

stevemitchell@bacchus:~$ sudo fdisk -l | grep 'Disk /'
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sda: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors

sudo vgcreate guest_images_lvm /dev/sda1
  Volume group "guest_images_lvm" successfully created
stevemitchell@bacchus:~$
sudo vgcreate guest_ssd_lvm /dev/nvme0n1p1
  Volume group "guest_ssd_lvm" successfully created
```
```shell
sudo hostnamectl set-hostname nike.byteworksinc.com --static

stevemitchell@nike:~$ sudo fdisk -l | grep 'Disk /'
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sdb: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk /dev/sdc: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors

sudo vgcreate guest_images_lvm /dev/sda1
  Volume group "guest_images_lvm" successfully created
sudo vgcreate guest_ssd_lvm /dev/nvme0n1p1
  Volume group "guest_ssd_lvm" successfully created


```
