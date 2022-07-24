# Build Images for Raspberry Pi Cluster

The most recent addition to KX.AS.CODE has been to add ARM64 support, stating with the first bare metal install on a Raspberry Pi 4 cluster!

This guide will detail the steps for building the Raspberry Pi image. For deployment, see the deployment guide.

!!! danger
    The deployment has only been tested on an 8GB Raspberry Pi 4B. It is not recommended to use anything less, as the resources will not be sufficient to run all the KX.AS.CODE services! Also note that one Raspberry Pi 4B will not be enough. In our testing, we have used four Raspberry Pi 4 boards set up in a 1 x KX-Main and 3 x KX-Workers configuration. Just ensure you have what is needed to deploy the images, before spending time to build the images. See the deployment guide for hardware needed and other pre-requisites.

First of all, thanks go out to `solo-io` and `mkaczanowski` who built the plugins for packer, to enable this function! Here are their repositories.

1. https://github.com/solo-io/packer-plugin-arm-image
2. https://github.com/mkaczanowski/packer-builder-arm/

We decided to go for the 2nd option, which was inspired by the first, due to some additional features, that we don't go into detail here.

So, without further ado, here the dependencies to get the build environment going.

As always, start by checking out the KX.AS.CODE GitHub repository.

```bash
git checkout https://github.com/Accenture/kx.as.code.git
```

Then 