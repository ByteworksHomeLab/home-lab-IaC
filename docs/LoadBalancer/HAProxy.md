# HAProxy

https://www.haproxy.com/blog/how-to-install-haproxy-on-ubuntu

## [ Hardware Requirements ](https://github.com/pingcap/docs/blob/master/best-practices/haproxy-best-practices.md#hardware-requirements)

| Hardware resource  | Minimum specification           |
|--------------------|---------------------------------|
| CPU                | 2 cores, 3.5 GHz                |
| Memory             | 16 GB                           |
| Storage            | 50 GB (SATA)                    |
| Network            | Interface Card 10G Network Card |

## [ Software Requirements ](https://github.com/pingcap/docs/blob/master/best-practices/haproxy-best-practices.md#software-requirements)


| Linux distribution       | Version |
|--------------------------|---------|
| Red Hat Enterprise Linux | 7 or 8  |
| CentOS                   | 7 or 8  |
| Oracle Enterprise Linux  | 7 or 8  |
| Ubuntu                   | LTS     |

The improved Let's Encrypt support starts in haproxy-2.8, but Ubnutu 22.04 has haproxy-2.4.4. Follow these instructions to get 2.8 (update the commands to 2.8):

https://linuxhint.com/install-configure-haproxy-ubuntu-22-04/

```shell
sudo add-apt-repository ppa:vbernat/haproxy-2.8 -y
sudo apt-get update
sudo apt install haproxy -y
```


https://www.redhat.com/sysadmin/reverse-proxy-ansible


frontend homelab
bind :80
use_backend athena  if { path /athena } || { path_beg /athena/ }
use_backend neptune if { path /neptune } || { path_beg /neptune/ }

backend athena
http-request replace-path /athena(/)?(.*) /\2
server server1 neptune.byteworksinc.com:9090 check maxconn 30

backend neptune
http-request replace-path /neptune(/)?(.*) /\2
server server1 neptune.byteworksinc.com:9090 check maxconn 30


https://webhostinggeeks.com/howto/how-to-setup-haproxy-as-load-balancer-for-nginx-on-ubuntu/
https://webhostinggeeks.com/howto/how-to-setup-haproxy-for-high-availability-with-keepalived/

