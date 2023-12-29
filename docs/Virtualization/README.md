# LXD

## Install LXD

```shell
sudo lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What IP address or DNS name should be used to reach this server? [default=192.168.3.3]:
Are you joining an existing cluster? (yes/no) [default=no]: no
What member name should be used to identify this server in the cluster? [default=neptune]:
Do you want to configure a new local storage pool? (yes/no) [default=yes]:
Name of the storage backend to use (dir, lvm, zfs, btrfs) [default=zfs]: dir
Do you want to configure a new remote storage pool? (yes/no) [default=no]:
Would you like to connect to a MAAS server? (yes/no) [default=no]: no
Would you like to configure LXD to use an existing bridge or host interface? (yes/no) [default=no]: yes
Name of the existing bridge or host interface: br0
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: yes
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: no
```

## Add a node

From the first node in the cluster:

```shell
lxc cluster add athena
To start your first container, try: lxc launch ubuntu:22.04
Or for a virtual machine: lxc launch ubuntu:22.04 --vm

Member athena join token:
eyJzZXJ2ZXJfbmFtZSI6ImF0aGVuYSIsImZpbmdlcnByaW50IjoiMzI4N2Y0NWZiYTIyNjhmNTE0MzNjMmYxNzhhNWM2NjgxOGEwZjEwMjZjYjM3NGYyY2VjMjI0NzFkY2Y4ZGEzZSIsImFkZHJlc3NlcyI6WyIxOTIuMTY4LjMuMzo4NDQzIl0sInNlY3JldCI6ImYwODllZjM1ZDgzZDk0MTQ0M2ViMmM2NTI5NDZjODM4MjRmYmZiODRlOTMxNjA1NGU0ODNhYjZiZjFlYzJmOTMiLCJleHBpcmVzX2F0IjoiMjAyMy0xMi0yOFQxOTo0Nzo1Ni4zMDU5MDQ4MDYtMDY6MDAifQ==
```

From the node to add:

```shell
sudo lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: yes
What IP address or DNS name should be used to reach this server? [default=192.168.3.4]:
Are you joining an existing cluster? (yes/no) [default=no]: yes
Do you have a join token? (yes/no/[token]) [default=no]: eyJzZXJ2ZXJfbmFtZSI6ImF0aGVuYSIsImZpbmdlcnByaW50IjoiMzI4N2Y0NWZiYTIyNjhmNTE0MzNjMmYxNzhhNWM2NjgxOGEwZjEwMjZjYjM3NGYyY2VjMjI0NzFkY2Y4ZGEzZSIsImFkZHJlc3NlcyI6WyIxOTIuMTY4LjMuMzo4NDQzIl0sInNlY3JldCI6ImYwODllZjM1ZDgzZDk0MTQ0M2ViMmM2NTI5NDZjODM4MjRmYmZiODRlOTMxNjA1NGU0ODNhYjZiZjFlYzJmOTMiLCJleHBpcmVzX2F0IjoiMjAyMy0xMi0yOFQxOTo0Nzo1Ni4zMDU5MDQ4MDYtMDY6MDAifQ==
All existing data is lost when joining a cluster, continue? (yes/no) [default=no] yes
Choose "source" property for storage pool "local":
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

Repeat for each LXD node in the LXD clusters.

## Launch VMs and Containers

Use container when virtualizing the same OS since it shares the kernel with LXD host. Containers can't be used to run different operating system versions. Use Virtual Machines when you need to run a different operation system.

Adding the `--vm` switch to the `lxc launch` command tells LXC to run as a VM.

Here is an example of launch a container for bind9.

Launch the container.

```shell
lxc launch ubuntu:22.04 ns1
```

Use `lxc list` to monitor the status.

| NAME |  STATE  |        IPV4         | IPV6 |   TYPE    | SNAPSHOTS | LOCATION |
|------|---------|---------------------|------|-----------|-----------|----------|
| ns1  | RUNNING | 192.168.3.52 (eth0) |      | CONTAINER | 0         | neptune  |
| ns2  | RUNNING | 192.168.3.53 (eth0) |      | CONTAINER | 0         | athena   |

## Example - Install Bind 9

For this example, we will install Bind9 following Ubuntu's [Domain Name Service](https://ubuntu.com/server/docs/service-domain-name-service-dns) instructions, but first,
we will connect and use netplan to assign static IP addresses.

```shell
lxc shell ns1
lxc shell ns2

lxc list
```

| NAME |  STATE  |        IPV4        | IPV6 |   TYPE    | SNAPSHOTS | LOCATION |
|------|---------|--------------------|------|-----------|-----------|----------|
| ns1  | RUNNING | 192.168.3.8 (eth0) |      | CONTAINER | 0         | neptune  |
| ns2  | RUNNING | 192.168.3.9 (eth0) |      | CONTAINER | 0         | athena   |

Install bind9

```shell
lxc exec ns1 -- sh -c "apt update && apt -y upgrade"
lxc exec ns1 -- sh -c "sudo apt install -y bind9 dnsutils"
```

Connect to the container to configure Bind.

```shell
lxc shell ns1
lxc shell ns2
```
