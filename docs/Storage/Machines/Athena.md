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

| Disk         | Model         | Size  | Type | Mount     | Purpose                  |
|--------------|---------------|-------|------|-----------|--------------------------|
| /dev/sda     | 30TT253X2-1T  | 512GB | EXT4 | /         | Boot, images, containers |
| /dev/nvme0n1 | WD Blue SN580 | 1TB   | ZFS  | /mnt/vol1 | ESB - Admin Cluster      |

Follow the ZFS instructions in the Storage section README file.

