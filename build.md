# Build



## Prerequisites

In order to build KX.AS.CODE, you will need the following pre-requisites

- HashiCorp Packer - https://www.packer.io/downloads
- Your chosen virtualization solution: 
  - VMWare Workstation/Fusion
  - Parallels Pro
  - VirtualBox - https://www.virtualbox.org/wiki/Downloads



Apart from Virtualbox, all of the above will need to be licensed.

#### VirtualBox Guest Additions

For VirtualBox you will need to ensure you have the matching guest additions version in the worker and master node json files:

```json
{
	"guest_additions_url": "https://download.virtualbox.org/virtualbox/6.1.16/VBoxGuestAdditions_6.1.16.iso",
	"guest_additions_checksum": "88db771a5efd7c048228e5c1e0b8fba56542e9d8c1b75f7af5b0c4cf334f0584"
}
```

To get the checksum, just visit the link https://download.virtualbox.org/virtualbox and navigate to the latest version. In the version directory you will see a file called "SHA256SUMS". Find the checksum for the ISO and add that to json files.

- base-vm\kx.as.code-main.json
- base-vm\kx.as.code-worker.json

You do not need to download the ISO files for the operating system or for the guest additions, as Packer will do this automatically.

### Debian ISO

Note, as Debian removed the old distributions, you may find that the build fails as it cannot download the latest ISO. This could happen if the build JSON files have not yet been updated. Again, go to the following site to determine the latest version and pick up the new checksum.

https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/



#### Parallels

Note, for Parallels you will need the pro edition, as without it, the build process will not work. See [here](https://www.packer.io/docs/builders/parallels) for more information.

Note that although you can build the VMWare images without a license, you will not be able to start up KX.AS.CODE with Vagrant if you do not have the license to the VMWare Desktop Vagrant plugin.

For vSphere, you need to build for VMWare desktop. The same OVA is used to deploy to both VMWare desktop and to VMWare vSphere.

#### Configuration

Before you can start building, you need to create a `variables.json` file, which will contain the passwords amongst others to be used during the build process. 

The contents of the JSON file must be as follows:

```json
{
     "acn_enterprise_id": "joe.bloggs",
     "acn_gitlab_token": "xjkwrd4534",
     "host_data_directory": "c:/Users/joe/KX_Share",
     "version": "0.5.1",
     "vm_user": "kx.hero",
     "vm_password": "L3arnandshare"
}
```



Here description for each parameter:

| Parameter           | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| acn_enterprise_id   | This is only relevant for internal Accenture builds, and is used for the checkout of the KX.AS.CODE repositories. |
| acn_gitlab_token    | This is only relevant for internal Accenture builds, and is used for the checkout of the KX.AS.CODE repositories. |
| host_data_directory | The directory that will be mapped to a share inside the VM to allow sharing of files between guest and host |
| version             | The version of the build                                     |
| vm_user             | The username for the default log in into the VM              |
| vm_password         | The password for the default log in into the VM              |



### Building on Windows

 

Start a shell session. This can be Powershell or WSL and enter trhe following command:

The `node type` must be either "main" or "worker", whilst the virtualization solution must be one of "vmwarer-desktop", "vmware-vsphere", "virtualbox" or parallels.

The only difference between vmware-desktop and vmware-vsphere is that for vmware-desktop the additional hard disks are already attached in the built OVA, whilst for vSphere, this is later taken care of by Terraform during the deployment process.

```bash
packer.exe build -force -only kx.as.code-{{node type}}-{{virtualization}}-desktop -var-file variables.json ./kx.as.code-main.json
```













### Building on MacOSX













