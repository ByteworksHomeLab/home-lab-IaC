# SSH Keys on Hosts

Add a `config` file to the hosts' `.ssh` dir.

```shell
vim ~/.ssh/confg
```

Add the following host-specific content.

```shell
# Global options
Host *
    # Use the specified private key for all hosts
    IdentityFile /home/stevemitchell/.ssh/id_rsa
    # Automatically add host keys to the known_hosts file
    # (Optional, but can be useful to avoid manual verifications)
    AddKeysToAgent yes
    StrictHostKeyChecking accept-new

# Configuration for host "Athena"
Host athena
    HostName 192.168.3.4
    User stevemitchell
```
## Share the public keys

Gather the contents of all the public keys and add them to each hosts' ~/.ssh/authorized_key file. Make sure you can `ssh` between hosts.

## Lock down the servers

```shell
sudo vi /etc/ssh/sshd_config
```

Edit the following in the Authentication section of the `sshd_config` file to block SSH logins:

```shell
PasswordAuthentication no
PubkeyAuthentication yes
```

Restart SSH

```shell
sudo systemctl restart ssh
```
Generate a key

```shell
ssh-keygen

cat ~/.ssh/id_rsa.pub
```

Add the to `~/.ssh/authorized_keys` on all the other hosts in the LXD cluster.

