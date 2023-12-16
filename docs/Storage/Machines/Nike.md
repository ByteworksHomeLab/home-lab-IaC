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

| Device              | Volume Group | Size   | Type | mount          | disk              |
|---------------------|--------------|--------|------|----------------|-------------------|
| /dev/nvme0n1        | ssd-vg       | 1T     | LVM  | /dev/nvme0n1p1 | WD Blue SN580 1TB |
| /dev/sda1           |              | 1G     | VFAT | /boot/efi      | WDC WD10SPZX-22Z  |
| /dev/sda2           |              | 2G     | EXT4 | /boot          | ""                |
| /dev/sda3           | ubuntu-vg    | 1T*    | LVM  | na             | ""                |
| /dev/sdb            | hdd-vg       | 2T     | LVM  | /dev/sdb1      | WDC WD20SPZX-22U  |
| /dev/sdc            | TBD          | 1T     | LVM  | /dev/sdc1      | ST1000DM003-1SB1  |

1) Create a new LVM volume group

```shell
sudo vgcreate hdd-vg /dev/sdb

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
sudo virsh pool-define-as hdd-pool logical - - /dev/sdb hdd-vg \ /dev/hdd-pool
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
  VG        #PV #LV #SN Attr   VSize    VFree
  hdd-vg      1   0   0 wz--n-   <1.82t   <1.82t
  ssd-vg      1   0   0 wz--n- <931.51g <931.51g
  ubuntu-vg   1   2   0 wz--n- <928.46g <728.46g
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
