# Raspberry Pi Cluster

The most recent addition to KX.AS.CODE has been to add ARM64 support, stating with the first bare metal install on a Raspberry Pi 4 cluster!

This guide will detail the steps for building the Raspberry Pi image. For deployment, see the deployment guide.

This is still a work in progress. You can follow our Raspberry Pi enablement progress on our [Discord Raspberry Pi channel](https://discord.gg/XC64HNgeXK){:target="\_blank"}!

!!! danger "Important"
    This has only been tested on an 8GB Raspberry Pi 4B. It is not recommended to use anything less, as the resources will not be sufficient to run all the KX.AS.CODE services! Also, note that one Raspberry Pi 4B will not be enough. In our testing, we have used four Raspberry Pi 4B boards set up in a 1 x KX-Main and 3 x KX-Workers configuration.

First of all, thanks go out to `solo-io` and `mkaczanowski` who built the ARM64 plugins for packer, which has allowed us to enable this function! Here are their repositories.

1. https://github.com/solo-io/packer-plugin-arm-image
2. https://github.com/mkaczanowski/packer-builder-arm/

We decided to go for the 2nd option, which was inspired by the first, due to some additional features, that we don't go into detail here.

So, without further ado, here the dependencies to get the build environment going.

As always, start by checking out the KX.AS.CODE GitHub repository and executing the following commands.

```bash
git checkout https://github.com/Accenture/kx.as.code.git
cd kx.as.code/base-vm/build/packer/raspberry-pi
vagrant plugin install vagrant-disksize # install this plugin if not yet available
vagrant up --provider virtualbox
```

This will start the build environment.

Next, ssh into that build environment with `vagrant ssh`.

Once inside the VM, cd into `/vagrant` and launch the builder for KX-Main, and KX-Node.

```bash
cd /kx.as.code/base-vm/build/packer/raspberry-pi/
cp ~/packer-builder-arm/packer-builder-arm /kx.as.code/base-vm/build/packer/raspberry-pi/

# Build the KX-Main image
sudo packer build ./kx-main-raspberrypi-arm64.json

# Build the KX-Node image
sudo packer build ./kx-node-raspberrypi-arm64.json
```

Once the images are built, they need to be flashed to the SD card.

Download and install the [Raspberry Pi imager](https://www.raspberrypi.com/news/raspberry-pi-imager-imaging-utility/).

Once installed, open it. and select the img you just built and the target SD card.

!!! danger "Important note!"
    Be 100% sure that you select the correct storage device in the Raspberry imaging device. To be safe, you may want to detach other removable storage. The imaging tool will remove all existing data from the target device!

![](../assets/images/Raspberry_PI_Setup_5.png){ loading=lazy }

Once the image is flashed to the SD card, you should be able to insert the SD card into the Raspberry Pi. Reboot it or switch it on, and you should see KX.AS.CODE starting up.

If you kept all the defaults, you can log in with `kx.hero` and `L3arnandshare`.

For more details on deploying the built images, see the [Raspberry Deployment Guide](../Deployment/Raspberry-Pi-Cluster.md).

!!! info
    This guide is still a work in progress.