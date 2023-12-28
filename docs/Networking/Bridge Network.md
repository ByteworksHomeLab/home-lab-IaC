# Configure the Bridge Network

https://www.wpdiaries.com/kvm-on-ubuntu/

Make sure networks are disabled in Cloud Config. Check for this file:

```shell
sudo cat /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
```

If it isn't there, to disable automated network configuration, create a file named `/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg` with this content:

```yaml
{config: disabled}
```

Disable `netfilter` for bridges.

create `/etc/sysctl.d/bridge.conf` with the content:

```text
net.bridge.bridge-nf-call-ip6tables=0
net.bridge.bridge-nf-call-iptables=0
net.bridge.bridge-nf-call-arptables=0
```

```
sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.conf
```

Create the file `/etc/udev/rules.d/99-bridge.rules`:

```text
ACTION=="add", SUBSYSTEM=="module", KERNEL=="br_netfilter", RUN+="/sbin/sysctl -p /etc/sysctl.d/bridge.conf"
```

# Machine Bridge Networks

Do the actual machine setup for each machine as shown in the machines network.

# Configure the br0 network in virsh

## Remove virbr0 from all machines

```shell
sudo virsh
net-destroy default
net-undefine default
exit
```

## Add the bridge to KVM

Create file `br0.xml.`
Create a file `br0.xml` in the home directory

```xml
<network>
  <name>br0</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
```

The following on all machines:

```shell
sudo virsh
net-define /home/stevemitchell/br0.xml
net-start br0
net-autostart br0
net-list
exit
```
