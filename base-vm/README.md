!["z2h_logo"](images/Zero2Hero_Logo_Black.png "z2h_logo")
# README

This repository contains all the files need to create the Zero-2-Hero KX.AS.CODE Ubuntu 19.10 virtual machine.

## Development Approach
`IMPORTANT NOTE:` All the kx.as.code developments MUST be accompanied by a `README.md` and/or `inline comments`! Pull requests will only be merged into the main branch if all documentation as to usage of new feature is included!

## Configuration Dependencies
- First, create a copy of `variables.json.example` and call it `variables.json`
- You must configure `variables.json` to contain the following items and put it in the same folder as `z2h_kx.as.code.json`

## Recommended Build Environment
- Whilst it is possible to build using Windows Powershell, it is recommended when running the build on Windows, to use Git Bash.
- This means that you do not need to edit the configuration files to work with Windows, as they will work as already checked into Bitbucket.
- If you do want to run the packer build in Powershell, the changes you need to make are documented below.

##### variables.json:
*MacOSX and Windows Git Bash*\
Note the different environment variable used to determine the host data directory for `MacOSX`, `Windows Git Bash` and `Windows Powershell`.
```json
{
  "acn_git_user": "{{env `LOGNAME`}}",
  "acn_bitbucket_password": "",
  "host_data_directory": "{{env `HOME`}}/Z2H_Data"
}
```

*Windows Powershell* \
Note the different environment variable used to determine the host data directory for `Windows Powershell`.
```json
{
  "acn_git_user": "{{env `LOGNAME`}}",
  "acn_bitbucket_password": "",
  "host_data_directory": "{{env `USERPROFILE`}}/Z2H_Data"
}
```

## Build Process

### VirtualBox

##### Prerequisites
- The VirtualBox vagrant provisioning plugin is required.
Install it with the following command:
```bash
$ vagrant plugin install vagrant-virtualbox
```
- The Ubuntu 19.10 server iso. It will download automatically if not present.
- The VirtualBox guest additions. It will download automatically if not present.

##### License Requirements
None. The Vagrant VirtualBox plugin is already included as default.

#### Build & Deployment Commands

```bash
# Build
$ packer build -only z2h_kx.as.code-virtualbox -var-file variables.json ./z2h_kx.as.code.json

# Add the box to Vagrant
$ vagrant box add z2h_kx.as.code-virtualbox virtualbox/z2h_kx.as.code-virtualbox.box --force

# Start the generated VMWare Virtual Box
$ VAGRANT_VAGRANTFILE=Vagrantfile.VirtualBox
$ vagrant up --provider virtualbox
```

### Parallels
##### Prerequisites
- The parallels vagrant provisioning plugin is required.
Install it with the following command:
```bash
$ vagrant plugin install vagrant-parallels
```
- The Ubuntu 19.10 server iso. It will download automatically if not present.
- Parallels Tools iso. You can obtain the iso from your installed Parallels installation:
```bash
$ cp /Applications/Parallels\ Desktop.app/Contents/Resources/Tools/prl-tools-lin.iso ./iso
```

##### License Requirements
The free automated vagrant provisioning plugin only works with the `pro` version of Parallels Desktop.
This currently cost `€99/year`.

#### Build & Deployment Commands

```bash
# Build
$ packer build -only z2h_kx.as.code-parallels -var-file variables.json ./z2h_kx.as.code.json

# Add the box to Vagrant
$ vagrant box add z2h_kx.as.code-parallels parallels/z2h_kx.as.code-parallels.box --force

# Start the generated Parallels Vagrant Box
$ export VAGRANT_VAGRANTFILE=Vagrantfile.Parallels
$ vagrant up --provider parallels
```

### VMWare
##### Important change
- You must now ensure that you have the VMWare OVF tool available on the comman line before building, else you will not get the OVA file output at the end.
On OSX, the location is as follows:
/System/Volumes/Data/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool
You can export using the following command:
```bash
# Either add it to your .bashrc or .zshrc and restart your shell session, or execute the line directly on the command line before executing the build
export PATH="$PATH:/System/Volumes/Data/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool"
```

##### Optional Prerequisites
- The VMWare vagrant provisioning plugin is required IF you plan to start the VM "BOX" up with vagrant, otherwise just import the "OVA" that is also produced during the build process directly into your VMWare environment.

Install it with the following command:
```bash
# Do not install the older vagrant-vmware-fusion plugin!
$ vagrant plugin install vagrant-vmware-desktop
```
- The Ubuntu 19.10 server iso. It will download automatically if not present.

##### License Requirements
A license must be purchased for the Vagrant provisioner.\
Current cost is `$79`.
To install the license, you need to complete the following step:

```bash
$ vagrant plugin license vagrant-vmware-desktop /path/to/license.lic
```
#### Build & Deployment Commands

```bash
# Build
$ packer build -only z2h_kx.as.code-vmware -var-file variables.json ./z2h_kx.as.code.json

# Add the box to Vagrant
$ vagrant box add z2h_kx.as.code-vmware vmware/z2h_kx.as.code-vmware.box --force

# Start the generated VMWare Vagrant Box
$ VAGRANT_VAGRANTFILE=Vagrantfile.VMWare
$ vagrant up --provider vmware_desktop
```


## External Dependencies

- [GDM Theme GIT Repository][]
- [Python Theme GIT Repository][]

## Versions Tested With
- [Packer][]
- [Vagrant][]
- [VirtualBox][]
```diff
Packer
+ 1.4.5
+ 1.5.1
+ 1.5.4
Vagrant
+ 2.2.4
+ 2.2.6
+ 2.2.7
VirtualBox
+ 6.0.14
+ 6.1.4  # This now also works with 6.1.4
```


[Packer]: https://packer.io/
[Vagrant]: https://www.vagrantup.com/
[VirtualBox]: https://www.virtualbox.org/
[GDM Theme GIT Repository]: https://innersource.accenture.com/scm/kxas/z2h_gdm_theme.git
[Python Theme GIT Repository]: https://innersource.accenture.com/scm/kxas/z2h_plymouth_theme.git
