# Bacchus

Show file system

```shell
sudo vgs
  VG        #PV #LV #SN Attr   VSize    VFree
  ubuntu-vg   1   1   0 wz--n- <928.46g <828.46g
  
sudo pvscan
  PV /dev/sdb3   VG ubuntu-vg       lvm2 [<928.46 GiB / <828.46 GiB free]
  Total: 1 [<928.46 GiB] / in use: 1 [<928.46 GiB] / in no VG: 0 [0   ]
  
sudo lvscan
  ACTIVE            '/dev/ubuntu-vg/ubuntu-lv' [100.00 GiB] inherit
  
sudo lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ubuntu-lv ubuntu-vg -wi-ao---- 100.00g
  
```

Clean up old volumes if needed:
```shell
virsh pool-list --all
virsh pool-destroy vmdisks
virsh pool-delete vmdisks
virsh pool-undefine vmdisks

sudo vgremove vmdisks
```

```shell
df -Th
Filesystem                        Type   Size  Used Avail Use% Mounted on
/dev/sdb2                         ext4   2.0G  130M  1.7G   8% /boot
/dev/sdb1                         vfat   1.1G  6.1M  1.1G   1% /boot/efi
```

```shell
 sudo fdisk -l 
 
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WD Blue SN580 1TB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F74F4F31-F6EA-4FBA-A4DB-B30152FB0DA8

Device         Start        End    Sectors   Size Type
/dev/nvme0n1p1  2048 1953523711 1953521664 931.5G Linux LVM


Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: TOSHIBA DT01ACA1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes


Disk /dev/sdc: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: ST1000DM003-1CH1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 65C4F092-8F37-4C00-8A00-FA30446B4C8C

Device       Start        End    Sectors   Size Type
/dev/sdc1     2048    2203647    2201600     1G EFI System
/dev/sdc2  2203648    6397951    4194304     2G Linux filesystem
/dev/sdc3  6397952 1953521663 1947123712 928.5G Linux filesystem


Disk /dev/sda: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk model: ST2000DM008-2FR1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes


Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 928.46 GiB, 996923146240 bytes, 1947115520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```

| Disk            | Model            | Size | Type | Mount     | Purpose                  |
|-----------------|------------------|------|------|-----------|--------------------------|
| 	/dev/sda       | ST2000DM008-2FR1 | 2TB  | ZFS  | /mnt/vol2 | ESB - Shared Services    |
| 	/dev/sdb       | TOSHIBA DT01ACA1 | 1TB  | ZFS  | /mnt/vol3 | Local storage pool       |
| 	/dev/sdc       | ST1000DM003-1CH1 | 1TB  | LVM  | /         | Boot, images, containers |
| 	/dev/nvme0n1 | WD Blue SN580    | 1TB  | ZSF  | /mnt/vol1 | ESB - Dev Cluster        |
