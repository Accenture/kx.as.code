# Private Clouds

So far KX.AS.CODE has been tested on both VMWare vSphere and OpenStack. That said, OpenStack has been used the most and is most likely not to experience issues.
vSphere was successfully tested with an older version of KX.AS.CODE, but would like to work without adjustments to the terraform scripts as things stand now.

To start KX.AS.CODE in OpenStack, you need to change into the OpenStack profiles directory and update the profile-config.json.

In this guide I will only go into the OpenStack specifics, as the general setup is already described in the "Initial Setup" guide.

!!! tip
    If you don't have access to an OpenStack cluster, but want to try it out, then follow our [OpenStack setup guide](../Prerequisites/OpenStack-Setup.md)

Before you get started, see the following [documentation from Packer](https://www.packer.io/plugins/builders/openstack){:target="\_blank"} to see how the OpenStack packer builder works.

The most important part of the packer build process are the packer JSON files themselves. Here are their location, depending on the OS from where you are launching the build process from.

#### Windows

- [Kx-Main](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/windows/kx-main-local-profiles.json){:target="\_blank"}
- [KX-Node](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/windows/kx-node-cloud-profiles.json){:target="\_blank"}

#### Mac/Linux

- [Kx-Main](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/darwin-linux/kx-main-cloud-profiles.json){:target="\_blank"}
- [KX-Node](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/darwin-linux/kx-node-cloud-profiles.json){:target="\_blank"}

There is not a huge difference between Windows and Mac/Linux. Certainly KX.AS.CODE is built in exactly the same way, just some of the post processing steps differ, due to differing terminal sessions (Powershell versus Bash for example)

### Prerequisites

- Access to an OpenStack cluster
- Sufficient rights to build images
- Access to the Debian base image
- Access to the internet

## Building

Building the images is already covered in the [OpenStack-Setup Guide](../Prerequisites/OpenStack-Setup.md), so will not be repeated here.

For deploying to OpenStack after you have built the images, see the following [guide](../Deployment/Private-Clouds.md).
