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
lxc launch images:ubuntu/22.04 kubeadm-leader --profile k8s-leader
````

Customize the running LXC container for K8S.

## Create a Bootstrap Cluster API server

First, follow the instructions [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). Install every EXCEPT for kubeadm to that we can publish that as a custom LXC image to use for other K8S nodes. You will need to stop the container before publishing it.

```shell
  lxc exec kubeadm-leader bash
```
Install some helpful packages
```shell
apt upgrade
apt install -y wget curl net-tools dnsutils
```

Install the containerd runtime

Refer to these instructions, [hHow to install the Containerd runtime engine on Ubuntu Server 22.04](https://www.techrepublic.com/article/install-containerd-ubuntu/).

Download the package.

```json
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
        
curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service

systemctl daemon-reload
systemctl enable --now containerd
systemctl status containerd
```

Install Kubernetes

See [Installing kubeadm, kubelet and kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

```shell
apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gpg
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
sudo sysctl --system
```

Initialize the cluster

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

```shell
lxc config set kubeadm-leader linux.kernel_modules ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter
lxc config set kubeadm-leader security.privileged "true"
lxc config set kubeadm-leader security.nesting "true"
printf 'lxc.apparmor.profile=unconfined\nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw sys:rw cgroup:rw\nlxc.cap.drop=' | lxc config set kubeadm-leader raw.lxc -
```
Make a snapshot and create an image:
```shell
lxc snapshot kubeadm-leader backup-kubeadm-image
lxc publish kubeadm-leader/backup-kubeadm-image --alias kubeadm-v1.29
```
Relaunch the container.

```shell
lxc start kubeadm-leader
```


I did not find a way to fix the `kubeadm init` preflight errors with `modprobe` on LXC Containers. This article discusses the same experience, [s](https://thelastguardian.me/posts/2020-01-10-kubernetes-in-lxc-on-proxmox/#:~:text=Kubernetes%20Cluster%20in%20LXC%20on%20multi%2Dnode%20Proxmox) and they ended up adding `--ignore-preflight-errors=SystemVerification` to the init command..

One last bit of housekeeping for the cluster is its pod network cidr. An [on line cidr range calculator](https://mxtoolbox.com/subnetcalculator.aspx) is helpful in this exercise.

In my case, my home lab VLAN was set to 192.168.1.3/24
. In order to achieve two non-overlapping cidr blocks, I change the VLAN subnet 10.0.0.0/16
, giving it 65,536 IPs in a range of 10.0.0.0 - 10.0.255.255. I also restricted the VLAN DHCP range to 10.0.0.100 - 10.0.0.255, reserving the first 25 addresses for static assignments. This allowed me to use assign the pod network cidr range to 10.0.96.0/20
. 

```shell
$ kubeadm init --ignore-preflight-errors=SystemVerification --pod-network-cidr=10.0.96.0/20
[init] Using Kubernetes version: v1.29.0
[preflight] Running pre-flight checks
[preflight] The system verification failed. Printing the output from the verification:
KERNEL_VERSION: 5.15.0-91-generic
OS: Linux
CGROUPS_CPU: enabled
CGROUPS_CPUSET: enabled
CGROUPS_DEVICES: enabled
CGROUPS_FREEZER: enabled
CGROUPS_MEMORY: enabled
CGROUPS_PIDS: enabled
CGROUPS_HUGETLB: enabled
CGROUPS_IO: enabled
	[WARNING SystemVerification]: failed to parse kernel config: unable to load kernel module: "configs", output: "modprobe: FATAL: Module configs not found in directory /lib/modules/5.15.0-91-generic\n", err: exit status 1
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
W0107 23:00:01.434684    9644 checks.go:835] detected that the sandbox image "registry.k8s.io/pause:3.8" of the container runtime is inconsistent with that used by kubeadm. It is recommended that using "registry.k8s.io/pause:3.9" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubeadm-leader kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.0.0.117]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubeadm-leader localhost] and IPs [10.0.0.117 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubeadm-leader localhost] and IPs [10.0.0.117 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "super-admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 5.003672 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node kubeadm-leader as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node kubeadm-leader as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: b3rsgx.s2q2viht6vl8hrhg
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.0.117:6443 --token b3rsgx.s2q2viht6vl8hrhg \
	--discovery-token-ca-cert-hash sha256:65b6b06881ea6cd6ebaf38dfff927bd743178d7bcbf8430abd8397b811af94ab
```

Follow the instructions shown above.

```shell
export KUBECONFIG=/etc/kubernetes/admin.conf
  
```

Let's pick up with [Bootstrapping clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/.)

Install Calico network operator. See [Calico instructions](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)

```shell
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml -O
```

EDIT ipPool inside custom-resources.yaml 

```shell
vim custom-resources.yaml
```
Change the `cidr` property under the `ipPools` section to match the `pod-network-cidr` passed to the `kubeadm init` command.

```shell
 This section includes base Calico installation configuration.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.0.96.0/20
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
````

Finally, deploy the Calico System.

```shell
kubectl create -f custom-resources.yaml
watch kubectl get pods -n calico-system
```

Install `calicoctl`
[Install calicoctl](https://docs.tigera.io/calico/latest/operations/calicoctl/install)

```shell
cd /usr/local/bin/
curl -L https://github.com/projectcalico/calico/releases/download/v3.27.0/calicoctl-linux-amd64 -o kubectl-calico
chmod +x ./kubectl-calico
kubectl calico -h
```

Create a snapshot.

```shell
lxc snapshot kubeadm-leader backup-kubeadm-calico
```

## Add a worker node 

```shell
lxc launch kubeadm-v1.29 kubeadm-worker1 --profile=k8s-leader
lxc exec kubeadm-worker1 bash
kubeadm join 10.0.0.117:6443 --token b3rsgx.s2q2viht6vl8hrhg --ignore-preflight-errors=SystemVerification --discovery-token-ca-cert-hash sha256:65b6b06881ea6cd6ebaf38dfff927bd743178d7bcbf8430abd8397b811af94ab
```
, , or. Only one form can be used.




