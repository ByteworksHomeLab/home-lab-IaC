# Neptune

Show file system

```shell
sudo pvscan
  PV /dev/sda3      VG ubuntu-vg       lvm2 [235.42 GiB / 0    free]
  
sudo vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  ubuntu-vg   1   1   0 wz--n- 235.42g      0

sudo lvscan
  ACTIVE            '/dev/ubuntu-vg/ubuntu-lv' [235.42 GiB] inherit
  
df -Th
Filesystem                        Type   Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv ext4    98G   29G   65G  31% /
/dev/sda2                         ext4   2.0G  258M  1.6G  15% /boot
/dev/sda1                         vfat   1.1G  6.1M  1.1G   1% /boot/efi

 sudo fdisk -l 

Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WD Blue SN580 1TB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


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

| Disk         | Model         | Size  | Type | Mount     | Purpose                  |
|--------------|---------------|-------|------|-----------|--------------------------|
| /dev/sda     | KingFast      | 512GB | LVM  | /         | Boot, images, containers |
| /dev/nvme0n1 | WD Blue SN580 | 1TB   | ZFS  | /mnt/vol1 | ESB - Admin Cluster      |

