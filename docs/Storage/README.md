# ZFS Storage Setup

## Install ZFS

```shell
sudo apt update
sudo apt install -y zfsutils-linux
whereis zfs
```
## Format the ZFS Drive

Repeat this section for each machine for any ZFS drives.

Follow the [instructions to format the drive with ZFS](https://openzfs.github.io/openzfs-docs/Getting%20Started/Ubuntu/Ubuntu%2018.04%20Root%20on%20ZFS.html#step-2-disk-formatting).

Export the drive name for use below:

```shell
DISK=/dev/nvme0n1
```

Run this if the drive was previously in a ZFS group
```shell
sudo apt install --yes mdadm
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
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: WD Blue SN580 1TB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: EFA6D43B-6278-48A2-93FE-6149FA58D8C4

Device         Start        End    Sectors   Size Type
/dev/nvme0n1p4  2048 1953525134 1953523087 931.5G Solaris /usr & Apple ZFS
```
## Mount the drive

Check the existing ZFS mounts with this command. See [ZFS Mound documentation](https://docs.google.com/spreadsheets/d/1B3QW3YYZDAb_-14d2l6ip5vvQTMkJBC1-guPpswTvM8/edit#gid=0).

```shell
sudo zfs mount
```

The drive is automatically mounted once added to a ZFS pool. Follow these instructions to create a pool for the $DISK above. In the this example, the name of the pool is 'vol1'.

```shell
sudo zpool create vol1 $DISK
sudo zpool status
sudo zfs mount
```

The drive is now mounted in the root directory by its pool name.

```shell
cd /vol1
ls -al
```
