# Remote Virtual Manager

We'll be running Virtual Manager from out MacBook, so it needs [Virtual Manager from Brew](https://www.arthurkoziel.com/running-virt-manager-and-libvirt-on-macos/).

Start `libvirt` with this command.
```shell
brew services start libvirt
```

Restart `libvirt`with this command.
```shell
brew services restart libvirt
```


# Install KVM, Qemu, and virtlib

Follow the virtualization instructions for your OS. In my case, I'm following [KVM on Ubuntu Bare Metal](https://www.wpdiaries.com/kvm-on-ubuntu/#kvm-packages). I had to go in to the BIOS for all three of my Xeon computers and enable virtualization. You will see this output when the hardware is ready:

# Install KVM, QEMU and libvirt

```shell
sudo apt install -y cpu-checker
sudo kvm-ok

INFO: /dev/kvm exists
KVM acceleration can be used
```
If you don't get a similar message, you may need to enabled virtualization in your computer BIOS.

Install the KVM, QEUM, and virtlib packages.

```shell
sudo apt install -y qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils nftables ovmf swtpm
```

```shell
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd
```

```shell
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
```
