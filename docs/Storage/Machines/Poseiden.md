# Poseiden

Show file system

```shell
sudo pvscan
[sudo] password for ubuntu:
  No matching physical volumes found
  
sudo vgs

sudo lvscan
  
df -Th
Filesystem     Type   Size  Used Avail Use% Mounted on
/dev/sda2      ext4   118G  3.7G  109G   4% /
/dev/sda1      vfat   253M  126M  127M  50% /boot/firmware

 sudo fdisk -l 

Disk /dev/sda: 119.24 GiB, 128035676160 bytes, 250069680 sectors
Disk model: 2115
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 33553920 bytes
Disklabel type: dos
Disk identifier: 0xe9508f59

Device     Boot  Start       End   Sectors  Size Id Type
/dev/sda1  *      2048    526335    524288  256M  c W95 FAT32 (LBA)
/dev/sda2       526336 250069646 249543311  119G 83 Linux

```

| Device           | Volume Group | Size | Type | mount          | disk              |
|------------------|--------------|------|------|----------------|-------------------|
| /dev/sdb1        |              | 1G   | VFAT | /boot/efi      | KingFast          |
| /dev/sdb2        |              | 2G   | EXT4 | /boot          | ""                |
| /dev/sdb3        | ubuntu-vg    | 1T*  | LVM  | na             | ""                |

1) Create the directories

```shell
sudo mkdir /isos
sudo chgrp libvirt /isos
sudo chmod g+w /isos
```

```shell
sudo mkdir /ssd-pool
sudo chgrp libvirt /ssd-pool
sudo chmod g+w /ssd-pool
```

2) Define the LVM Storage Pools


```shell
virsh pool-define-as ssd-pool dir - - - - "/ssd-pool"
```

3) Build the pool

```shell
virsh pool-build ssd-pool 
```

4) Initialize the new pool.

```shell
virsh pool-start ssd-pool
```

5) Turn on autostart

```shell
virsh pool-autostart ssd-pool
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
