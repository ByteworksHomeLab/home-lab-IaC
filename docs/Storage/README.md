# ZFS Storage Setup

Look at your devices before starting:

```shell
sudo lsblk
```

## Install ZFS

```shell
sudo apt update
sudo apt install -y zfsutils-linux mdadm
whereis zfs
```

## Format the ZFS Drive

Repeat this section for each machine for any ZFS drives. The [table of drive mounts can be found here](https://docs.google.com/spreadsheets/d/1B3QW3YYZDAb_-14d2l6ip5vvQTMkJBC1-guPpswTvM8/edit#gid=0).

Follow the [instructions to format the drive with ZFS](https://openzfs.github.io/openzfs-docs/Getting%20Started/Ubuntu/Ubuntu%2018.04%20Root%20on%20ZFS.html#step-2-disk-formatting).

Export the drive name for use below:

```shell
DISK=/dev/nvme0n1
```

Run this if the drive was previously in a ZFS group
```shell
sudo mdadm --zero-superblock --force $DISK
```

Clear the partition table:

```shell
sudo sgdisk --zap-all $DISK
```
Choose one of the following options:

- Unencrypted

```shell
sudo sgdisk     -n4:0:0        -t4:BF01 $DISK
```

- LUKS

```shell
sudo sgdisk     -n4:0:0        -t4:8300 $DISK
```

Verify the drive

```shell
$ sudo fdisk $DISK -l

Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WD Blue SN580 1TB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 363C477B-0C85-4D24-AF23-A0AB4A7F8001

Device         Start        End    Sectors   Size Type
/dev/nvme0n1p4  2048 1953525134 1953523087 931.5G Solaris /usr & Apple ZFS

```
## Mount the drive

Check the existing ZFS mounts with this command. See [ZFS Mount documentation](https://docs.oracle.com/cd/E19253-01/819-5461/gamns/index.html).

Pick the appropriate command
```
# All hosts
sudo zpool create ssd1-pool $DISK -f -m /mnt/ssd1-pool

# ONLY Bacchus, Nike, and Zeus
sudo zpool create hdd1-pool $DISK -f -m /mnt/hdd1-pool
sudo zpool create hdd2-pool $DISK -f -m /mnt/hdd2-pool
```

Verify the ZFS pools are complete on all posts using the`zfs list` and `lsblk` commands.

List Block Devices

Before being mounted, the ZFS drives do not appear in this list.

```shell
$ lsblk

NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0 931.5G  0 disk
├─sda1                      8:1    0     1G  0 part /boot/efi
├─sda2                      8:2    0     2G  0 part /boot
└─sda3                      8:3    0 928.5G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 928.5G  0 lvm  /
sdb                         8:16   0 931.5G  0 disk
├─sdb1                      8:17   0 931.5G  0 part
└─sdb9                      8:25   0     8M  0 part
sdc                         8:32   0   1.8T  0 disk
├─sdc1                      8:33   0   1.8T  0 part
└─sdc9                      8:41   0     8M  0 part
nvme0n1                   259:0    0 931.5G  0 disk
├─nvme0n1p1               259:3    0 931.5G  0 part
└─nvme0n1p9               259:4    0     8M  0 part
```

ZFS List

```shell
$ zfs list

NAME        USED  AVAIL     REFER  MOUNTPOINT
hdd1-pool   420K  1.76T       96K  /mnt/hdd1-pool
hdd2-pool   432K   899G       96K  /mnt/hdd2-pool
ssd1-pool   123K   899G       24K  /mnt/ssd1-pool
```

Creating volumes

Create a plan.

| Host    | Zpool     | Volume      | Size  | Mount     |
|---------|-----------|-------------|-------|-----------|
| Athena  | ssd1-pool | worker1-vol | 899 G | /mnt/ssd1 |
| Neptune | ssd1-pool | worker1-vol | 899 G | /mnt/ssd1 |
| Bacchus | ssd1-pool | worker1-vol | 899 G | /mnt/ssd1 |
| Bacchus | hdd1-pool | shared1-vol | 1.8T  | /mnt/hdd1 |
| Bacchus | hdd2-pool | shared2-vol | 899 T | /mnt/hdd2 |
| Nike    | ssd1-pool | worker1-vol | 899 G | /mnt/ssd1 |
| Nike    | hdd1-pool | shared1-vol | 1.8T  | /mnt/hdd1 |
| Nike    | hdd2-pool | shared2-vol | 899 T | /mnt/hdd2 |
| Zeus    | ssd1-pool | worker1-vol | 899 G | /mnt/ssd1 |
| Zeus    | hdd1-pool | shared1-vol | 1.8T  | /mnt/hdd1 |
| Zeus    | hdd2-pool | shared2-vol | 899 T | /mnt/hdd2 |

Pool `ssd1-pool`

Run on each LXD host, except for Poseidon, Athena, and Neptune which only have the `ssd1-pool` Zpool.

```shell
sudo zfs create -V 800G ssd1-pool/worker1-vol
sudo zfs create -V 1.6G hdd1-pool/shared1-vol
sudo zfs create -V 800G hdd2-pool/shared2-vol
```

Verify the results

```shell
$ zfs list

NAME                    USED  AVAIL     REFER  MOUNTPOINT
hdd1-pool              1.65G  1.75T       96K  /mnt/hdd1-pool
hdd1-pool/shared1-vol  1.65G  1.76T       56K  -
hdd2-pool               825G  74.2G       96K  /mnt/hdd2-pool
hdd2-pool/shared2-vol   825G   899G       56K  -
ssd1-pool               825G  74.2G       24K  /mnt/ssd1-pool
ssd1-pool/worker1-vol   825G   899G       12K  -
```

```shell
lxc storage volume attach <pool-name> <volume-name> <container-name> <device-name> path=</some/path/in/the/container>
lxc storage volume attach ssd1-pool k8s2-vol1 k8s-shared-1 <device-name> path=/mnt/vol1
```
