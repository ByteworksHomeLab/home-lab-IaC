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
