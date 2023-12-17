# Athena

Show file system

```shell
 sudo fdisk -l 

Disk /dev/sda: 953.87 GiB, 1024209543168 bytes, 2000409264 sectors
Disk model: 30TT253X2-1T
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 09098F54-CC50-4997-B7BC-623BF4BB3C07

Device       Start        End    Sectors   Size Type
/dev/sda1     2048    1050623    1048576   512M EFI System
/dev/sda2  1050624 2000408575 1999357952 953.4G Linux filesystem

```

| Device    | Volume Group | Size | Type | mount          | disk              |
|-----------|--------------|------|------|----------------|-------------------|
| /dev/sda1 |              | 1G   | VFAT | /boot/efi      | ST1000DM003-1CH1  |
| /dev/sda2 |              | 2G   | EXT4 | /boot          | ""                |
| /dev/sda3 | ubuntu-vg    | 1T*  | LVM  | na             | ""                |

1) Make a directory for ISO images

```shell
sudo mkdir /isos
sudo chgrp libvirt /isos
sudo chmod g+w /isos
```

2) Define the LVM Storage Pools


```shell
virsh pool-define-as hdd-pool dir - - - - "/hdd-pool"
```

3) Build the pool

```shell
virsh pool-build hdd-pool 
```

4) Initialize the new pool.

```shell
virsh pool-start hdd-pool
```

5) Turn on autostart

```shell
virsh pool-autostart hdd-pool
```

Verify status

```shell
virsh pool-list --all
 Name               State    Autostart
----------------------------------------
 hdd-pool           active   yes
```

5) Create a test volume on each

```shell
virsh vol-create-as hdd-pool volume1 8G
```

Verify

```shell
virsh vol-list hdd-pool
 Name      Path
------------------------------------------
 hdd-volume1   /dev/hdd-pool/hdd-volume1
  
```
