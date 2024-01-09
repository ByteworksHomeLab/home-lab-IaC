# Incus

Incus is a replacement of LXD.

## Installation

To install Incus, follow the [GitHub Zabbly README for Incus](https://github.com/zabbly/incus).

Finish the install by adding your user to the group.

```shell
sudo adduser stevemitchell incus-admin
newgrp incus-admin
```

Adding containers

```shell
incus launch images:ubuntu/22.04 ns1
```

Changing config

```shell
incus config set ns1 security.privileged "true"
printf 'lxc.apparmor.profile=unconfined\nlxc.mount.auto=proc:rw sys:rw cgroup:rw\nlxc.cap.drop=' | incus config set ns1 raw.lxc -
```

