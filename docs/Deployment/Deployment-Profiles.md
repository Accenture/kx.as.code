# Deployment Profiles

The concept of `deployment profiles` was introduced to support KX.AS.CODE across different local virtualization and cloud platform solutions.

These deployment profiles include everything needed to start KX.AS.CODE on the respective platform.

All local profiles are started with `Vagrant`, whilst cloud targeted profiles are started with `Terraform`. 

!!! info
    Each profile has a `profile-config.json`, which describes exactly what should be started and how it should be configured once KX.AS.CODE comes up. See [here](../../Deployment/Configuration-Options/) for the full documentation of all the configurable profile properties.

Here is a list of the platforms for which there are currently up-to-date and tested profiles.

!!! tip
    Currently VirtualBox and OpenStack are the most regularly tested solutions.

| Profile | Deployment via... | Supported Host OSs | Supported Hardware |
| --- | --- | --- | --- | 
| [Parallels](https://github.com/Accenture/kx.as.code/tree/main/profiles/vagrant-parallels){:target="\_blank"} | Vagrant | MacOSX | x86_64 |
| [VirtualBox](https://github.com/Accenture/kx.as.code/tree/main/profiles/vagrant-virtualbox){:target="\_blank"} | Vagrant | MacOSX, Linux, Windows | x86_64 |
| [VMWare Workstation / Fusion](https://github.com/Accenture/kx.as.code/tree/main/profiles/vagrant-vmware-desktop){:target="\_blank"} | Vagrant | MacOSX, Linux, Windows | x86_64 |
| [AWS](https://github.com/Accenture/kx.as.code/tree/main/profiles/terraform-aws){:target="\_blank"} | Public Cloud | Terraform | n/a |
| [OpenStack](https://github.com/Accenture/kx.as.code/tree/main/profiles/terraform-openstack){:target="\_blank"} | Private Cloud | Terraform | n/a |

!!! warning
    ARM based processors are currently not supported, so it is not possible to run KX.AS.CODE on a MacBook with an M1 or M2 processor, nor a Raspberry Pi. That said, work is in progress to enable it! See here[](../../Build/Raspberry-Pi-Cluster/).

!!! info 
    There has been some testing with `VMWare vSphere` in the past, but due to lack of a test environment, the scripts haven't been updated for a while.

The solution has never been tested on `GCP` or `Azure`, but there is no reason for it not to work, and it should be easy enough to do, taking the `AWS` solution as inspiration.

With all the cloud based solutions, the images need to be build. In the case of AWS that's an `AMI`, for OpenStack, the images are in `QCOW2` format.
See the dedicated build guides for AWS and OpenStack to achieve this.

If anyone has access to a `GCP` or `Azure` account and wants to try it out, reach out to us. Should be easy enough.

!!! tip
    The local virtualization profiles can be started with the [Jenkins based launcher](../../Deployment/Initial-Setup/). This is the reocmmended approach for starting KX.AS.CODE for the local virtualizations, as there are additional checks and validations in place, reducing the potential for error."

KX.AS.CODE for private and public clouds need to be started manually by first updating the `profile-config.json`, and then launching it via `terraform` with `terraform init` and `terraform apply`.

See deploying KX.AS.CODE on [Local Virtualizations platforms](../../Deployment/Local-Virtualizations/) for additional hints for starting KX.AS.CODE locally.