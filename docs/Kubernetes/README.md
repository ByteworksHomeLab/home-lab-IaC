# Kubernetes

## Installation

See the following:
* [Terraform LXD provisioner documentation](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/instance).

## Create a K8S profile on the LXD Cluster

Follow this article,  [A step by step demo on Kubernetes cluster creation](https://medium.com/geekculture/a-step-by-step-demo-on-kubernetes-cluster-creation-f183823c0411), to setup the profiles shown below. Stop before launching the profiles.

```shell
lxc profile copy default k8s-leader
lxc profile copy default k8s-worker
```

The Athena, Neptune, and Poseidon machines have 32 GB RAM and 4 - 8 threads, therefore, the 'k8s-leader' profile will use limits of 4 cores and 16 GB RAM.

Edit the k8s-leader profile.
```shell
lxc profile edit k8s-leader
```

```shell
config:
  limits.cpu: "4"
  limits.memory: 8GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,nf_nat,overlay,br_netfilter
  raw.lxc: "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw
    sys:rw"
  security.nesting: "true"
  security.privileged: "true"
description: K8S profile for a cluster leader node
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: br0
    type: nic
  root:
    path: /
    pool: local
    type: disk
name: k8s-leader
used_by:
```

The Bacchus, Nike, and Zeus machines have 96 GB RAM and 20 threads, therefore, the 'k8s-worker' profile will use limits of 10 cores and 48 GB RAM.

Edit the k8s-leader profile.
```shell
lxc profile edit k8s-master
```

```shell

config:
  limits.cpu: "10"
  limits.memory: 48GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,nf_nat,overlay,br_netfilter
  raw.lxc: "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw
    sys:rw"
  security.nesting: "true"
  security.privileged: "true"
description: K8S profile for a cluster worker node
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: br0
    type: nic
  root:
    path: /
    pool: local
    type: disk
name: k8s-worker
used_by: []
```

## Making a Custom LXC image for Kubernetes

Launch one `k8s-leader` container in which to do the basic Kubernetes setup. 

```shell
lxc launch images:ubuntu/22.04 k8s-leader1 --profile k8s-leader
````

Customize the running LXC container for K8S.

## Create a Bootstrap Cluster API server

First, follow the instructions [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). Install every EXCEPT for kubeadm to that we can publish that as a custom LXC image to use for other K8S nodes. You will need to stop the container before publishing it.

```shell
  lxc launch images:ubuntu/22.04 mgmt-leader --profile k8s-leader
  lxc exec mgmt-leader bash
```
Install the containerd runtime

Refer to these instructions, [hHow to install the Containerd runtime engine on Ubuntu Server 22.04](https://www.techrepublic.com/article/install-containerd-ubuntu/).

Download the package.

```json
apt update
apt install -y wget
wget https://github.com/containerd/containerd/releases/download/v1.7.11/containerd-1.7.11-linux-amd64.tar.gz
```

Unpack it into /usr/local

```json
tar Cxzvf /usr/local containerd-1.7.11-linux-amd64.tar.gz
```
Install runc

```json
wget https://github.com/opencontainers/runc/releases/download/v1.1.11/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
```

Install the CNI (Container Network Interface)

```json
wget https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz
```

Configure CNI

```json
mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

apt install -y curl
curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd
```

Install Kubernetes

See [Installing kubeadm, kubelet and kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

```shell
apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

Follow this block of instructions on the host node (not the LXC container).

```shell
echo br_netfilter | sudo tee -a /etc/modules
cat <<EOF | tee /etc/modules
overlay
br_netfilter
EOF

sudo modprobe br_netfilter
sudo modprobe overlay

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system
```

```shell

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
 
# DO NOT RUN MODPROBE ON A LXC CONTAINER
# See https://github.com/containerd/cri/issues/878#issuecomment-437579928
# modprobe overlay
# modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system
```

Initialize the cluster

The `kubeadm init` command fail on an LXC container unless you disable the `modprobe` check.
See https://github.com/containerd/cri/issues/878#issuecomment-437579928

```Shell
vim -p /etc/systemd/system/containerd.service.d/00-nomodprobe.conf
```

Add the following content to the file.
```text
[Service]
ExecStartPre=
```

Getting Kubernetes to run on an LXC container. There is a bit more work to make Kubernetes work in a LXC Container rather tha a LXC  Virtual Machine.

We start with the article [Kubernetes inside Proxmox LXC](https://kevingoos.medium.com/kubernetes-inside-proxmox-lxc-cce5c9927942).

Uncomment `net.ipv4.ip_forward=1` in `/etc/sysctl.conf` to enable packet forwarding.

```shell
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
```
Add a new line to the sysctl.conf file:
```shell
vm.swapiness=0
```
If you haven't already, disable swapping on the LXC host.

```shell
swapoff -a
```
Then, comment out the SWAP line in `/etc/fstab`.

Create a file, `/etc/rc.local` with the content below.

```shell
#!/bin/sh -e
# Kubeadm 1.15 needs /dev/kmsg to be there, but it’s not in lxc, but we can just use /dev/console instead
# see: https://github.com/kubernetes-sigs/kind/issues/662
if [ ! -e /dev/kmsg ]; then
ln -s /dev/console /dev/kmsg
fi
# https://medium.com/@kvaps/run-kubernetes-in-lxc-container-f04aa94b6c9c
mount --make-rshared /
```

Change the permissions and run the file.

```shell
chmod +x /etc/rc.local
/etc/rc.local
```

Continuing with the next article

See [Run kubernetes inside LXC container](https://kvaps.medium.com/run-kubernetes-in-lxc-container-f04aa94b6c9c)

The syntax changed since the article was written, so the steps to change the LXC container configuration after different below.

```Shell
echo -e "overlay\nbr_netfilter" >> /etc/modules
```

Run `lxc config show mgmt-leader` first can copy and paste the config somewhere else.

```shell
lxc config show mgmt-leader
```

Expose the some kernel modules to the LXC container and raise the privileges of the lxc container. 

```shell
lxc stop mgmt-leader
lxc config set mgmt-leader linux.kernel_modules ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter
lxc config set mgmt-leader security.privileged "true"
lxc config set mgmt-leader security.nesting "true"
```

Next, edit the config for `mgmt-leader` and add the `raw.lxc` block below the `image` properties. The output is truncated for the sake of brevity.

```shell
$ lxc config edit mgmt-leader
```

Add the `rax.lxc` block (5 lines) anywhere after the `image` properties. In actuality, the security properies are at the bottom of the file, but were included here for completeness.

```
architecture: x86_64
config:
  image.architecture: amd64
  image.description: Ubuntu jammy amd64 (20240104_07:42)
  image.os: Ubuntu
  image.release: jammy
  image.serial: "20240104_07:42"
  image.type: squashfs
  image.variant: default
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilte
  security.nesting: "true"
  security.privileged: "true"
  raw.lxc: |-
    lxc.apparmor.profile=unconfined
    lxc.cgroup.devices.allow=a
    lxc.mount.auto=proc:rw sys:rw cgroup:rw
    lxc.cap.drop=
  ... (truncated output here ...)
```

Relaunch the container.

```shell
lxc start mgmt-leader
```

Make a snapshot and create an image:
```shell
lxc snapshot mgmt-leader backup-kubeadm-image4
lxc publish mgmt-leader/backup-kubeadm-image4 --alias kubeadm-v1.29
```

Making the IP address of `mgmt-leader` Static

I'm added an `A` record in my DNS for this management cluster. That needs to be done prior to initialized Kubernetes. 

Start by finding the DHCP assigned address from the running container.

```shell
T ip a show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
20: eth0@if21: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:16:3e:4c:42:a5 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.3.66/24 metric 100 brd 192.168.3.255 scope global dynamic eth0
       valid_lft 86310sec preferred_lft 86310sec
    inet6 fe80::216:3eff:fe4c:42a5/64 scope link
       valid_lft forever preferred_lft forever
```

On the host, run these commands to see what networks are available.

```shell
lxc network list
+------+----------+---------+------+------+-------------+---------+-------+
| NAME |   TYPE   | MANAGED | IPV4 | IPV6 | DESCRIPTION | USED BY | STATE |
+------+----------+---------+------+------+-------------+---------+-------+
| br0  | bridge   | NO      |      |      |             | 6       |       |
+------+----------+---------+------+------+-------------+---------+-------+
| eno1 | physical | NO      |      |      |             | 0       |       |
+------+------
```

Run these commands to make it permanent using the network name found using `ip a show`.

```shell
lxc stop mgmt-leader
lxc network attach br0 mgmt-leader eth0
# lxc config device set mgmt-leader eth0 ipv4.address 192.168.3.66
lxc start mgmt-leader
```
I used an existing bridge on my host, so I could not use that third command:

```shell
lxc config device set mgmt-leader eth0 ipv4.address 192.168.3.66
Error: Invalid devices: Device validation failed for "eth0": Cannot use manually specified ipv4.address when using unmanaged parent bridge
```


I did not find a way to fix the `kubeadm init` preflight errors with `modprobe` on LXC Containers. This article discusses the same experience, [s](https://thelastguardian.me/posts/2020-01-10-kubernetes-in-lxc-on-proxmox/#:~:text=Kubernetes%20Cluster%20in%20LXC%20on%20multi%2Dnode%20Proxmox) and they ended up adding `--ignore-preflight-errors=SystemVerification` to the init command..

```shell
lxc exec mgmt-leader bash
kubeadm init  --ignore-preflight-errors=SystemVerification
```



