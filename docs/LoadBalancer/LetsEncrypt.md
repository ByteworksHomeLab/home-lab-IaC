# HAProxy with Let's Encrypt

https://www.haproxy.com/blog/haproxy-and-let-s-encrypt

install socat

```shell
sudo apt-get install socat
```

See https://statuslist.app/uptime-monitoring/haproxy/haproxy-stats-socket-guide/

```shell
global
        # stats socket <bind> level <admin|operator|user>
        stats socket /var/run/haproxy.sock mode 600 level admin
        stats timeout 2m
```

Add user

```shell
sudo adduser \
   --system \
   --disabled-password \
   --disabled-login \
   --home /var/lib/acme \
   --quiet \
   --force-badname \
   --group \
   acme
sudo adduser acme haproxy
```

Add Let's Encrypt

```shell
sudo mkdir /usr/local/share/acme.sh/
git clone https://github.com/acmesh-official/acme.sh.git
cd acme.sh/
sudo ./acme.sh \
   --install \
   --no-cron \
   --no-profile \
   --home /usr/local/share/acme.sh
sudo ln -s /usr/local/share/acme.sh/acme.sh /usr/local/bin/
sudo chmod 755 /usr/local/share/acme.sh/
```
Install the hook

```shell
curl https://raw.githubusercontent.com/haproxy/haproxy/master/admin/acme.sh/haproxy.sh | sudo tee /usr/local/share/acme.sh/deploy/haproxy.sh
```

Generate your ACME account

```shell
sudo -u acme -s
acme.sh --register-account \
   -m alerts@byteworksinc.com
exit 
touch: cannot touch '/home/stevemitchell/.acme.sh/http.header': No such file or directory
[Wed Dec 20 05:35:50 PM UTC 2023] Create account key ok.
[Wed Dec 20 05:35:50 PM UTC 2023] Registering account: https://acme-staging-v02.api.letsencrypt.org/directory
[Wed Dec 20 05:35:51 PM UTC 2023] Registered
```

Create a directory for the certificates:

```shell
sudo mkdir /etc/haproxy/certs
sudo chown haproxy:haproxy /etc/haproxy/certs
sudo chmod 770 /etc/haproxy/certs
```

Update  /etc/haproxy/haproxy.cfg

```shell
sudo vi /etc/haproxy/haproxy.cfg 
```

```shell

Add the Thumbprint from Let's Encript

global
    setenv ACCOUNT_THUMBPRINT 'random thrumbprint string'
    
frontend web
    bind :80
    bind :443 ssl crt /etc/haproxy/certs/ strict-sni
    http-request return status 200 content-type text/plain lf-string "%[path,field(-1,/)].${ACCOUNT_THUMBPRINT}\n" if { path_beg '/.well-known/acme-challenge/' }
```

Generate a certificate

```shell
sudo -u acme -s
acme.sh --issue \
   --debug 2 \
   --dns dns_ovh \
   -d byteworksinc.com \
   -d *.byteworksinc.com \
   --stateless
```
