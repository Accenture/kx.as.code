# Public Cloud

## AWS

Currently, the KX.AS.CODE image builds have been tested on AWS only as far as public clouds is concerned. The solution will also work on other public clouds, but these have not yet been tested.
Here the instructions for building the AMI images needed to launch KX.AS.CODE on AWS.

First, understand how the packer build process for AWS works by reading the following [documentation](https://learn.hashicorp.com/tutorials/packer/aws-get-started-build-image?in=packer/aws-get-started){:target="\_blank"}.

### Prerequisites

- Packer installed
- An AWS account with secret key and secret
- Route to the internet in the AWS network where the packer build will be launched

### Packer Build

Unlike with the local setup, for the private and public clouds, the build process has to be kicked off manually from the command line.

Before you get started, see the following [documentation from Packer](hhttps://www.packer.io/plugins/builders/amazon){:target="\_blank"} to see how the AWS AMI packer builder works.

The most important part of the packer build process are the packer JSON files themselves. Here are their location, depending on the OS from where you are launching the build process from.

#### Windows

- [Kx-Main](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/windows/kx-main-local-profiles.json){:target="\_blank"}
- [KX-Node](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/windows/kx-node-cloud-profiles.json){:target="\_blank"}

#### Mac/Linux

- [Kx-Main](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/darwin-linux/kx-main-cloud-profiles.json){:target="\_blank"}
- [KX-Node](https://github.com/Accenture/kx.as.code/blob/main/base-vm/build/packer/darwin-linux/kx-node-cloud-profiles.json){:target="\_blank"}

There is not a huge difference between Windows and Mac/Linux. Certainly KX.AS.CODE is built in exactly the same way, just some of the post processing steps differ, due to differing terminal sessions (Powershell versus Bash for example)

### Executing the build

To execute the build, gather all the parameters needed below.

One of the parameters is the Debian 11 AMI id to use as the base image, on top of which the KX.AS.CODE scripts will be run. You can get it [here](https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye).

#### KX-Main (Control-plane + infrastructure + admin tools)

```bash
    # AWS Packer Build Variables
    export aws_ami_groups="" # Enter the correct value here
    export aws_vpc_region="" # Enter the correct value here
    export aws_vpc_id="" # Enter the correct value here
    export aws_vpc_subnet_id="" # Enter the correct value here
    export aws_availability_zone="" # Enter the correct value here
    export aws_associate_public_ip_address=true
    export aws_source_ami=ami-049ed5fa529109ac4 # This should be the base AMI id for Debian 11
    export aws_security_group_id="" # Enter the correct value here
    export aws_instance_type=t3.small
    export aws_shutdown_behavior=terminate
    export aws_ssh_username=admin
    export aws_ssh_interface=public_ip
    export aws_compute_engine_build=true
    
    # Specific variables for KX-Main. Not needed for KX-Node.
    export git_source_url=https://github.com/Accenture/kx.as.code.git
    export git_source_branch=main
    export git_source_user="<your github user>"  # optional, only needed for private repositories
    export git_source_token="<your github token>"  # optional, only needed for private repositories
    
    # Your AWS access key and secret
    export AWS_PACKER_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxxxxxxxx"
    export AWS_PACKER_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxx"

    cd base-vm/build/packer/${packerOsFolder}
    ${packerPath}/packer build -force -only kx.as.code-main-aws-ami \
    -var "compute_engine_build=${aws_compute_engine_build}" \
    -var "hostname=${kx_main_hostname}" \
    -var "domain=${kx_domain}" \
    -var "version=${kx_version}" \
    -var "vm_user=${kx_vm_user}" \
    -var "vm_password=${kx_vm_password}" \
    -var "instance_type=${aws_instance_type}" \
    -var "access_key=${AWS_ACCESS_KEY_ID}" \
    -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
    -var "git_source_url=${git_source_url}" \
    -var "git_source_branch=${git_source_branch}" \
    -var "git_source_user=${git_source_user}" \
    -var "git_source_token=${git_source_token}" \
    -var "source_ami=${aws_source_ami}" \
    -var "ami_groups=${aws_ami_groups}" \
    -var "vpc_region=${aws_vpc_region}" \
    -var "availability_zone=${aws_availability_zone}" \
    -var "vpc_id=${aws_vpc_id}" \
    -var "vpc_subnet_id=${aws_vpc_subnet_id}" \
    -var "associate_public_ip_address=${aws_associate_public_ip_address}" \
    -var "ssh_interface=${aws_ssh_interface}" \
    -var "base_image_ssh_user=${aws_ssh_username}" \
    -var "shutdown_behavior=${aws_shutdown_behavior}" \
    ./kx.as.code-main-cloud-profiles.json
```

#### KX-Node (Kubernetes worker)

```bash
    # AWS Packer Build Variables
    export aws_ami_groups="" # Enter the correct value here
    export aws_vpc_region="" # Enter the correct value here
    export aws_vpc_id="" # Enter the correct value here
    export aws_vpc_subnet_id="" # Enter the correct value here
    export aws_availability_zone="" # Enter the correct value here
    export aws_associate_public_ip_address=true
    export aws_source_ami=ami-049ed5fa529109ac4 # This should be the base AMI id for Debian 11
    export aws_security_group_id="" # Enter the correct value here
    export aws_instance_type=t3.small
    export aws_shutdown_behavior=terminate
    export aws_ssh_username=admin
    export aws_ssh_interface=public_ip
    export aws_compute_engine_build=true
    
    # Your AWS access key and secret
    export AWS_PACKER_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxxxxxxxx"
    export AWS_PACKER_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxx"

  # Start the packer build process
    cd base-vm/build/packer/${packerOsFolder}
    packer build -force -only kx.as.code-worker-aws-ami \
        -var "compute_engine_build=true" \
        -var "hostname=kx-node" \
        -var "domain=${kx_domain}" \
        -var "version=${kx_version}" \
        -var "vm_user=${kx_vm_user}" \
        -var "vm_password=${kx_vm_password}" \
        -var "instance_type=${aws_instance_type}" \
        -var "access_key=${AWS_ACCESS_KEY_ID}" \
        -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
        -var "source_ami=${aws_source_ami}" \
        -var "ami_groups=${aws_ami_groups}" \
        -var "vpc_region=${aws_vpc_region}" \
        -var "availability_zone=${aws_availability_zone}" \
        -var "vpc_id=${aws_vpc_id}" \
        -var "vpc_subnet_id=${aws_vpc_subnet_id}" \
        -var "associate_public_ip_address=${aws_associate_public_ip_address}" \
        -var "ssh_interface=${aws_ssh_interface}" \
        -var "base_image_ssh_user=debian" \
        -var "shutdown_behavior=${aws_shutdown_behavior}" \
        ./kx-node-cloud-profiles.json
```

!!! note
    Remember to write down your AMI id once you have built the images. You will need to refer to them when deploying the built images.

Once the images are built, see the following [guide](../Deployment/Public-Clouds.md) on how to deploy them.
