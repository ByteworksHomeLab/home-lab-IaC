# Storage Overview

Examine the storage and plan the storage pools


## Setup

[12.4 LVM-based Storage Pools with virsh](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/create-lvm-storage-pool-virsh)

Examine the device an plan the use:

```shell
$ df -Th
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs   13G  2.2M   13G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    98G   12G   82G  13% /
tmpfs                             tmpfs   63G     0   63G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
tmpfs                             tmpfs   63G     0   63G   0% /run/qemu
/dev/sdb2                         ext4   2.0G  130M  1.7G   8% /boot
/dev/sdb1                         vfat   1.1G  6.1M  1.1G   1% /boot/efi
tmpfs                             tmpfs   13G  4.0K   13G   1% /run/user/1000

sudo fdisk -l | grep 'Disk /'
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sda: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 100 GiB, 107374182400 bytes, 209715200 sectors

sudo pvs
  PV             VG               Fmt  Attr PSize    PFree
  /dev/nvme0n1p1 guest_ssd_lvm    lvm2 a--  <931.51g <931.51g
  /dev/sda       guest_images_lvm lvm2 a--    <1.82t   <1.82t
  /dev/sdb3      ubuntu-vg        lvm2 a--  <928.46g <828.46g
```

1) Create a new LVM volume group
2) Define the LVM Storage Pools
3) Build the pool
4) Initialize the new pool.
5) Turn on autostart
6) Create a test volume on each


## Mount iSCSI initiator 

See https://www.server-world.info/en/note?os=Ubuntu_22.04&p=iscsi&f=3

```shell
sudo apt update
sudo apt-get install open-iscsi -y

sudo mkdir -p /nfs/isos
sudo chgrp -R adm /nfs
sudo chmod g+w -R /nfs
```

Edit `/etc/iscsi/initiatorname.iscsi` on all hosts and change the IQN you set on the iSCSI target server

```text
InitiatorName=iqn.2023-09.byteworksinc.com:bacchus.initiator01
```

Edit `/etc/iscsi/iscsid.conf`

# line 58 : uncomment
node.session.auth.authmethod = CHAP

# line 69,70: uncomment and specify the username and password you set on the iSCSI target server
node.session.auth.username = iqn.2023-09.byteworksinc.com:bacchus.initiator01
node.session.auth.password = silver338tuesday

```shell
sudo systemctl restart iscsid open-iscsi
sudo iscsiadm -m discovery -t sendtargets 192.168.3.10
```

# Let's encrypt

```shell
export AWS_ACCESS_KEY_ID=yyyyyyyy 
export AWS_SECRET_ACCESS_KEY=zzzzzzzz 
export AWS_DEFAULT_REGION=eu-west-1
```

## Download the certs

```shell
aws s3 cp --recursive s3://byteworksinc-ssl-certs/ca_certs /Users/stevemitchell/certs
```

Rename the files
```shell
mv certificate_pem  certificate.pem
mv issuer_pem issuer.pem
mv private_key_pem private_key.pem
```

Validate the files
```shell
openssl x509 -in certificate.pem -text -noout
```

## Fixed issue connecting to ZyXel NAS326

How to fix [no matching host key type found. Their offer: ssh-rsa,ssh-dss](https://www.youtube.com/watch?v=XqB3kMyZT1o).

Be sure to copy your host key to the ZyXel NAS326.

