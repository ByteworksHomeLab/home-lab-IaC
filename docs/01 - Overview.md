




# Storage Pools

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-virtualization-storage_pools-creating-lvm

```shell
sudo hostnamectl set-hostname bacchus --static

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

```shell
sudo fdisk -l | grep 'Disk /'
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sdc: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors

stevemitchell@zeus:~$
sudo vgcreate guest_images_lvm /dev/sda1
  Volume group "guest_images_lvm" successfully created
stevemitchell@zeus:~$
sudo vgcreate guest_ssd_lvm /dev/nvme0n1p1
  Volume group "guest_ssd_lvm" successfully created
stevemitchell@zeus:~$
sudo vgextend guest_images_lvm /dev/sdb1
  Volume group "guest_images_lvm" successfully extended
```
# Virt-Manager

To run virt-manager on your laptop use this command.

```shell
virt-manager -c "qemu:///session" --no-fork
```

To manage the Linux hosts from your laptop, [follow these instructions](https://gist.github.com/davesilva/da709c6f6862d5e43ae9a86278f79188) to open up the permission:

It is possible to launch directly to a remote machine like this example, but that is not what will do.

```shell
virt-manager --connect="qemu+ssh://$USER@bacchus/system?socket=/var/run/libvirt/libvirt-sock"
```

Instead, we'll run locally, like this.

```shell
virt-manager -c "qemu:///session" --no-fork
```

The Virtual Manager opens, click File --> Connection. Fill out the prompt like this.

<p align="center">
<img src="./images/virt-manager-connection.png" width="322" >
</p>

Add connections for all the machines, then close and re-open Virtual Manager show they were saved.

<p align="center">
<img src="./images/VirtualManagerHosts.png" width="802" >
</p>

## Other changes
Following this script: https://gitlab.com/stephan-raabe/archinstall/-/blob/main/7-kvm.sh, I updated qemu.conf:

```text
# ------------------------------------------------------
# Edit qemu.conf
# ------------------------------------------------------
echo "Manual steps required:"
echo "Open sudo vim /etc/libvirt/qemu.conf"
echo "Uncomment and add your user name to user and group."
echo 'user = "your username"'
echo 'group = "your username"'
read -p "Press any key to open qemu.conf: " c
sudo vim /etc/libvirt/qemu.conf
```

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

