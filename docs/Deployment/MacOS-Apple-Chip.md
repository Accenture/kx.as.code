# Deployment on a MacBook with ARM Chips (Apple M1, M2, ...)

This guide will detail how to deploy images from Vagrant Cloud to your local MacBook using qemu.

## Software Pre-requisites

This is the software stack used:
- Chip: >= Apple M1 Pro. Check at Apple --> About this Mac
- MacOS: >= Sonoma 14.2.1. Check at Apple --> About this Mac
- [Homebrew](https://brew.sh/)
- [Vagrant](https://developer.hashicorp.com/vagrant/install#darwin)
- Qemu: `brew install qemu`
- Vargrant plugin: `vagrant plugin install vagrant-qemu`

## Create Vagrant Qemu `kx-main` Instance

```shell
mkdir kx-master
cd kx-master
vagrant box add chtrautwein/kx-main
```

Create a file named `Vagrantfile`containing

```
Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "qemu"
  end
end

boximage = ENV["HOME"]+"/.vagrant.d/boxes/chtrautwein-VAGRANTSLASH-kx-main/0.8.16/arm64/libvirt/box_0.img"

Vagrant.configure("2") do |config|
  config.vm.box = "chtrautwein/kx-main"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # See https://github.com/ppggff/vagrant-qemu
  config.vm.provider "qemu" do |v|
    v.image_path = boximage
    v.extra_qemu_args = %w(-vnc 127.0.0.1:56 -device virtio-gpu -usb -device usb-ehci -device usb-kbd -device usb-mouse -device usb-tablet -boot order=cdi,splash-time=30,menu=on)
  end
end
```

## First time start of the `kx-main` instance

```shell
vagrant up --provider qemu
````

Use [VNC](https://www.realvnc.com/de/connect/download/viewer/) to connect to 127.0.0.1:56 . 
You should see UEFI trying to boot. 

![UEFI Boot attempt](../assets/images/uefi_firstboot_screenshot1.png)

Wait several minutes until you see the `UEFI Interactive Shell`

![](../assets/images/uefi_firstboot_screenshot2.png)

Type:
```shell
FS0:
ls
```

!!! tip
    Unfortunately you will not see what you type. You have to close and reopen the vnc connection to see the result.

Type: 
```shell
cd efi
cd debian
grubaa64.efi
```

![](../assets/images/uefi_firstboot_screenshot3.png)

A GRUB screen will show up

![](../assets/images/uefi_firstboot_screenshot4.png)

Just wait or select the first entry.

The login screen will show up.

![](../assets/images/uefi_firstboot_screenshot5.png)

## Set UEFI Boot Entry

Switch back to your local shell and enter
```shell
vagrant ssh
sudo efibootmgr --create --disk /dev/?da --part 1 --write-signature --label debian --loader '\EFI\debian\grubaa64.efi'
```