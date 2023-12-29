# Zeus

Show file system

```shell
sudo vgs
  VG          #PV #LV #SN Attr   VSize    VFree
  ubuntu-vg-1   1   1   0 wz--n- <928.46g <828.46g
  
sudo pvscan
  PV /dev/sda3        VG ubuntu-vg-1     lvm2 [<928.46 GiB / <828.46 GiB free]
  PV /dev/nvme0n1p1                      lvm2 [931.51 GiB]
  PV /dev/sdb1                           lvm2 [931.51 GiB]
  Total: 3 [<2.73 TiB] / in use: 1 [<928.46 GiB] / in no VG: 2 [<1.82 TiB]
  
sudo lvscan
  ACTIVE            '/dev/ubuntu-vg/ubuntu-lv' [100.00 GiB] inherit
  
sudo lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao---- 100.00g
```


```shell
df -Th
Filesystem                           Type   Size  Used Avail Use% Mounted on
/dev/sda2                            ext4   2.0G  130M  1.7G   8% /boot
/dev/sda1                            vfat   1.1G  6.1M  1.1G   1% /boot/efi
```

```shell
 sudo fdisk -l 
 
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WD Blue SN580 1TB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 0323DD27-4055-4DEA-941C-43622299B09F

Device         Start        End    Sectors   Size Type
/dev/nvme0n1p1  2048 1953523711 1953521664 931.5G Linux LVM


Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: ST1000DM003-1CH1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes


Disk /dev/sdc: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk model: WDC WD20EFZX-68A
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 025C917F-2E82-4E17-A24A-E189A4BC44DF

Device       Start        End    Sectors  Size Type
/dev/sdc1     2048    3999743    3997696  1.9G Linux RAID
/dev/sdc2  3999744    7999487    3999744  1.9G Linux RAID
/dev/sdc3  7999488 3907028991 3899029504  1.8T Linux RAID


Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: ST1000DM003-1ER1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: CCAF9C4F-8116-4EF6-88EF-FAEA70FB31FB

Device       Start        End    Sectors   Size Type
/dev/sda1     2048    2203647    2201600     1G EFI System
/dev/sda2  2203648    6397951    4194304     2G Linux filesystem
/dev/sda3  6397952 1953521663 1947123712 928.5G Linux filesystem

Disk /dev/mapper/ubuntu--vg--1-ubuntu--lv: 100 GiB, 107374182400 bytes, 209715200 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```

| Disk         | Model            | Size | Type | Mount     | Purpose                  |
|--------------|------------------|------|------|-----------|--------------------------|
| /dev/sda     | ST1000DM003-1ER1 | 1TB  | LVM  | /         | Boot, images, containers |
| /dev/sdb     | ST1000DM003-1CH1 | 1TB  | ZFS  | mnt/vol3  | Local storage pool       |
| /dev/sdc     | WDC WD20EFZX-68A | 2TB  | ZFS  | /mnt/vol2 | ESB - Shared Services    |
| /dev/nvme0n1 | WD Blue SN580    | 1TB  | ZFS  | /mnt/vol1 | ESB - Dev Cluster        |

Install ZFS.

```shell
sudo apt update
sudo apt install -y zfsutils-linux
```
Repeat the following commands for each non-boot drive.

