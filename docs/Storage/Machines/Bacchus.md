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


Disk /dev/sda: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
Disk model: ST2000DM008-2FR1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: B5AA8AF1-7B30-445A-AEB4-4E573E8455E4

Device     Start        End    Sectors  Size Type
/dev/sda1   2048 3907028991 3907026944  1.8T Linux LVM


Disk /dev/sdb: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: ST1000DM003-1CH1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: A70F39B7-A968-4E9E-B4C8-C81AC37EA89B

Device       Start        End    Sectors   Size Type
/dev/sdb1     2048    2203647    2201600     1G EFI System
/dev/sdb2  2203648    6397951    4194304     2G Linux filesystem
/dev/sdb3  6397952 1953521663 1947123712 928.5G Linux filesystem


Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 100 GiB, 107374182400 bytes, 209715200 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
```

| Device           | Volume Group | Size | Type | mount          | disk              |
|------------------|--------------|------|------|----------------|-------------------|
| /dev/nvme0n1     | ssd-vg       | 1T   | LVM  | /dev/nvme0n1p1 | WD Blue SN580 1TB |
| /dev/sda         | hdd-vg       | 2T   | LVM  | /dev/sda1      | ST2000DM008-2FR1  |
| /dev/sdb1        |              | 1G   | VFAT | /boot/efi      | ST1000DM003-1CH1  |
| /dev/sdb2        |              | 2G   | EXT4 | /boot          | ""                |
| /dev/sdb3        | ubuntu-vg    | 1T*  | LVM  | na             | ""                |

1) Create a new LVM volume group

```shell
sudo vgcreate hdd-vg /dev/sda
sudo vgcreate ssd-vg /dev/nvme0n1p1
```

1a) Make some space for ISO images

```shell
sudo lvcreate --name isos-lv -L 100G ubuntu-vg 
  Logical volume "isos-lv" created.
  
sudo mkfs.ext3 /dev/ubuntu-vg/isos-lv
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 26214400 4k blocks and 6553600 inodes
Filesystem UUID: 0c6a98e0-00a9-412a-8797-ea1a6307dd64
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
	4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done
Writing inode tables: done
Creating journal (131072 blocks): done
Writing superblocks and filesystem accounting information: done

sudo mkdir /isos
sudo mount /dev/ubuntu-vg-1/isos-lv /isos
sudo chgrp libvirt /isos
sudo chmod g+w /isos
```

Ensure this file system will automatically mount the next time the server is rebooted by adding the following entry to /etc/fstab:

```shell
/dev/ubuntu-vg/isos-lv        /isos                ext4 defaults    0 0
````


2) Define the LVM Storage Pools


```shell
sudo virsh pool-define-as hdd-pool logical - - /dev/sda hdd-vg \ /dev/hdd-pool
sudo virsh pool-define-as ssd-pool logical - - /dev/nvme0n1p1 ssd-vg \ /dev/ssd-pool

```

3) Build the pool

```shell
virsh pool-build hdd-pool --overwrite
virsh pool-build ssd-pool --overwrite

```

4) Initialize the new pool.

```shell
virsh pool-start hdd-pool
virsh pool-start ssd-pool
```
Verify

```shell
sudo vgs
  VG               #PV #LV #SN Attr   VSize    VFree
  hdd-pool           1   0   0 wz--n-   <1.82t   <1.82t
  ssd-pool           1   0   0 wz--n- <931.51g <931.51g
  ubuntu-vg          1   1   0 wz--n- <928.46g <828.46g
```

5) Turn on autostart

```shell
virsh pool-autostart hdd-pool
virsh pool-autostart ssd-pool
```

Verify status

```shell
virsh pool-list --all
 Name               State    Autostart
----------------------------------------
 hdd-pool           active   yes
 ssd-pool           active   yes
```

5) Create a test volume on each

```shell
virsh vol-create-as hdd-pool volume1 8G
virsh vol-create-as ssd-pool volume1 8G
```

Verify

```shell
virsh vol-list hdd-pool
 Name      Path
------------------------------------------
 hdd-volume1   /dev/hdd-pool/hdd-volume1

virsh vol-list ssd-pool
 Name          Path
-----------------------------------------------
 ssd-volume1   /dev/ssd-pool/ssd-volume1
 
 sudo lvscan
  ACTIVE            '/dev/ubuntu-vg/ubuntu-lv' [100.00 GiB] inherit
  ACTIVE            '/dev/ubuntu-vg/isos-lv' [100.00 GiB] inherit
  ACTIVE            '/dev/ssd-vg/volume1' [8.00 GiB] inherit
  ACTIVE            '/dev/hdd-vg/volume1' [8.00 GiB] inherit
  
sudo lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  volume1   hdd-vg    -wi-a-----   8.00g
  volume1   ssd-vg    -wi-a-----   8.00g
  isos-lv   ubuntu-vg -wi-ao---- 100.00g
  ubuntu-lv ubuntu-vg -wi-ao---- 100.00g
  
```
