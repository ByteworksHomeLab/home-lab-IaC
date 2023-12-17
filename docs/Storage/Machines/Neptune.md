# Neptune

Show file system

```shell
sudo pvscan
  PV /dev/sda3   VG ubuntu-vg       lvm2 [235.42 GiB / 135.42 GiB free]
  Total: 1 [235.42 GiB] / in use: 1 [235.42 GiB] / in no VG: 0 [0   ]
  
sudo vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  ubuntu-vg   1   1   0 wz--n- 235.42g 135.42g

sudo lvscan
  ACTIVE            '/dev/ubuntu-vg/ubuntu-lv' [100.00 GiB] inherit
  
df -Th
Filesystem                        Type   Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    98G   16G   78G  17% /
/dev/sda2                         ext4   2.0G  252M  1.6G  14% /boot
/dev/sda1                         vfat   1.1G  6.1M  1.1G   1% /boot/efi

 sudo fdisk -l 

Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 500118192 sectors
Disk model: KingFast
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 0ADFB7FD-2772-48AF-842D-D1CBCB49E730

Device       Start       End   Sectors   Size Type
/dev/sda1     2048   2203647   2201600     1G EFI System
/dev/sda2  2203648   6397951   4194304     2G Linux filesystem
/dev/sda3  6397952 500115455 493717504 235.4G Linux filesystem

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
