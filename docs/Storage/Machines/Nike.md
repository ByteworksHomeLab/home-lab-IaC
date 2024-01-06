# Nike

Show file system

```shell
sudo vgs
  VG        #PV #LV #SN Attr   VSize    VFree
  ubuntu-vg   1   1   0 wz--n- <928.46g <828.46g
  
sudo pvscan
[sudo] password for stevemitchell:
  PV /dev/sda3        VG ubuntu-vg       lvm2 [<928.46 GiB / <828.46 GiB free]
  PV /dev/nvme0n1p1                      lvm2 [931.51 GiB]
  PV /dev/sdb1                           lvm2 [<1.82 TiB]
  PV /dev/sdc3                           lvm2 [928.46 GiB]
  Total: 4 [4.54 TiB] / in use: 1 [<928.46 GiB] / in no VG: 3 [<3.64 TiB]
  
sudo lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao---- 100.00g
```

```shell
df -Th
Filesystem                        Type   Size  Used Avail Use% Mounted on
/dev/sda2                         ext4   2.0G  130M  1.7G   8% /boot
/dev/sda1                         vfat   1.1G  6.1M  1.1G   1% /boot/efi
```

```shell
  sudo fdisk -l

Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WD Blue SN580 1TB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 05CD974F-EC17-4754-9579-84967C2C1A36

Device         Start        End    Sectors   Size Type
/dev/nvme0n1p1  2048 1953523711 1953521664 931.5G Linux LVM


Disk /dev/sdb: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk model: WDC WD20SPZX-22U
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: F2C8E64E-5AE4-4A37-8296-262A6F143313

Device     Start        End    Sectors  Size Type
/dev/sdb1   2048 3907029134 3907027087  1.8T Linux LVM


Disk /dev/sdc: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: ST1000DM003-1SB1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 97C85EBC-787F-42E5-8D3E-CD753AEB9AFD

Device       Start        End    Sectors   Size Type
/dev/sdc1     2048    2203647    2201600     1G EFI System
/dev/sdc2  2203648    6397951    4194304     2G Linux filesystem
/dev/sdc3  6397952 1953521663 1947123712 928.5G Linux filesystem


Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WDC WD10SPZX-22Z
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: F37F7B3C-53E8-4FB8-A86D-DEE210106837

Device       Start        End    Sectors   Size Type
/dev/sda1     2048    2203647    2201600     1G EFI System
/dev/sda2  2203648    6397951    4194304     2G Linux filesystem
/dev/sda3  6397952 1953521663 1947123712 928.5G Linux filesystem


Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 100 GiB, 107374182400 bytes, 209715200 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```


| Disk         | Model            | Size | Type | Mount     | Purpose                  |
|--------------|------------------|------|------|-----------|--------------------------|
| /dev/sda     | WDC WD10SPZX-22Z | 1TB  | LVM  | /         | Boot, images, containers |
| /dev/sdb     | WDC WD20SPZX-22U | 2TB  | ZFS  | /mnt/vol2 | ESB - Shared Services    |
| /dev/sdc     | ST1000DM003-1SB1 | 1TB  | ZFS  | /mnt/vol3 | Local storage pool       |
| /dev/nvme0n1 | WD Blue SN580    | 1TB  | ZFS  | /mnt/vol1 | ESB - Dev Cluster        |
