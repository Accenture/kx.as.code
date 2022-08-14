# Setting up DevStack

If you would like to deploy KX.AS.CODE to OpenStack, but don't have an environment, follow the guide below to set up our own test environment.

## Initial Dev-Stack setup
For detailed instructions for setting up DevStack, see the following [guide](https://docs.openstack.org/devstack/latest/)

!!! tip
    At the time of writing, Ubuntu 20.04 is the most tested operating system used with DevStack. The instructions here assume you are using that distribution.

Here a short summary of the link provided above.
```bash
sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i
git clone https://opendev.org/openstack/devstack
cd devstack
```
!!! warning
    Don't run `./stack.sh` until you have completed further steps below

## General Points on Networking
It is recommended to have an additional NIC dedicated to the OpenStack public interface. In the example below, that is `eth1`.
You will need to enable promiscuous mode on that interface. Follow the instructions if using a virtual machine on how to enable that for your virtual network, otherwise, for a physical NIC you can do the following and reboot:
`sudo ip link set eth1 promisc on`

## Update local.conf
Here the shorted version without all the comments:
<pre><code>ADMIN_PASSWORD=<b><i>[enter your desired OpenStack admin password here]</i></b>
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

VOLUME_GROUP_NAME="stack-volumes"
VOLUME_GROUP="stack-volumes"

<code style="color: rgb(0 0 0 / 54%); font-size: 1em;"># Uncomment below line if using an LVM with physical drives as a DevStack storage volume
#CINDER_ENABLED_BACKENDS=lvm

# Uncomment below lines if using a local file as a DevStack storage volume
#VOLUME_NAME_PREFIX="volume-"
#VOLUME_BACKING_FILE_SIZE=1500G
</code>
GLANCE_LIMIT_IMAGE_SIZE_TOTAL=100000
IMAGE_URLS="http://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2,https://cdimage.debian.org/cdimage/cloud/bullseye/latest/debian-11-generic-amd64.qcow2,"
LIBVIRT_TYPE=kvm
PUBLIC_INTERFACE=eth1  # change this to match the NIC you allocated to DevStack
HOST_IP=192.200.76.201  # In our test setup this matches the IP of the PUBLIC_INTERFACE defined above
LOGFILE=$DEST/logs/stack.sh.log
LOGDAYS=2
LOG_COLOR=True
VERBOSE=True
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data
</code>
</pre>


## Update /etc/sysctl.conf
Depending on your NIC names, and the NIC you intend to use for the DevStack public interface, set the following (in the example below, the public interface is `eth1`):
```bash
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.all.rp_filter=0
net.ipv4.ip_forward=1
net.ipv4.conf.eth1.proxy_arp=1
net.ipv6.conf.all.forwarding=1
```

## Install additional net-tools
`apt install bridge-utils net-tools`

## Fix inc/python file
To fix a dependency error when running `stack.sh`, it is necessary to do a minor fix

Open `/opt/stack/devstack/inc/python` and edit line `198`
Add `--ignore-installed` to line `198`, so it is changed to

`$cmd_pip $upgrade --ignore-installed \`


## Fix neutron_plugins/ovn_agent file
The next fix solves an error during `stack.sh` execution with `ovn`.

Open `/opt/stack/devstack/lib/neutron_plugins/ovn_agent` and edit line `114`

Change

`OVS_RUNDIR=$OVS_PREFIX/var/run/openvswitch`

to

`OVS_RUNDIR=$OVS_PREFIX/var/run/ovn`


## Install arping fix

```bash
wget http://de.archive.ubuntu.com/ubuntu/pool/main/i/iputils/iputils-arping_20210202-1_amd64.deb
apt install -y ./iputils-arping_20210202-1_amd64.deb
```

## Setup Stack Data Mount
!!! info
    There are a few ways to provide storage to your DevStack install. Through a logical volume mount with phyisical drives (virtual drives if not on bare metal), or a volume file. Both are described below. Follow one of the two guides depending on your setup.

### Virtual Stack Volume file
```bash
sudo losetup -f /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
sudo losetup -f --show /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
sudo vgcreate stack-volumes-lvmdriver-1 /dev/loop9  # use the output from the --show command above to determine which /dev/loop device to use

vi /etc/lvm/lvm.conf
filter = [ "a/loop9/", "r/.*/"]   # should be the loop device identified above

```

### Physical Drives
```bash
vgremove stack-volumes
vgcreate stack-volumes /dev/nvme0n1 /dev/nvme1n1 # change to match the name of your physical drives

vi /etc/lvm/lvm.conf
filter = [ "a/nvme0n1/", "a/nvme1n1/", "r/.*/"] # change to match the name of your physical drives
```

!!! info
    Once you have completed all the above, you are ready to launch `./stack.sh`. Once done, you can proceed to the next steps below

## Update nova settings
In order to avoid timeout issues (default is 3 minutes) creating block devices, update the nova.conf file as follows:
```bash
[DEFAULT]
..
..
block_device_allocate_retries=600
block_device_allocate_retries_interval=3
```

!!! danger "Important"
    Not updating this setting will result in the following error message when provisioning VMs in OpenStack with large block storage: `[Error: Build of instance 5c7eb729-03c6-489f-899c-c748416ca6ae aborted: Volume 71169a26-ec13-4fa6-b14c-ce66560a7d45 did not finish being created even after we waited 184 seconds or 61 attempts. And its status is downloading.]`

## Set authentication for CLI
Execute the following before executing any `openstack` commands, else they will fail with an unauthorized message.
```bash
. /opt/stack/devstack/openrc admin
export OS_AUTH_TOKEN=$(openstack token issue -c id -f value)
unset OS_USERNAME
unset OS_PASSWORD
unset OS_PROJECT_DOMAIN_ID
unset OS_PROJECT_DOMAIN_NAME
unset OS_USER_DOMAIN_NAME
```

## Setup DevStack Storage file
```bash
sudo losetup -f /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
sudo losetup -f --show /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
sudo vgcreate stack-volumes-lvmdriver-1 /dev/loop9

sudo vi /etc/lvm/lvm.conf
filter = [ "a/sdb/", "a/sdc/", "a/loop9/", "r/.*/"]

# Restart OpenStack
sudo systemctl restart devstack@*

# Check if OpenStack volume service is now up
openstack volume service list

# Expected result output
+------------------+----------------+------+---------+-------+----------------------------+
| Binary           | Host           | Zone | Status  | State | Updated At                 |
+------------------+----------------+------+---------+-------+----------------------------+
| cinder-scheduler | os             | nova | enabled | up    | 2022-02-27T14:06:51.000000 |
| cinder-volume    | os@lvmdriver-1 | nova | enabled | up    | 2022-02-27T14:06:52.000000 |
+------------------+----------------+------+---------+-------+----------------------------+
```


## Set Limits
This is optional, but recommended. Not setting these to higher limits may result in errors when deploying KX.AS.CODE to OpenStack due to limited resouces.
```bash
openstack quota set --volumes 30 admin
openstack quota set --gigabytes 1700 admin
openstack quota set --snapshots 30 admin
```

## Update default security group
Update the security rules to enable SSH to the KX.AS.CODE virtual machines.

```bash
openstack security group rule create --proto icmp --dst-port 0 default
openstack security group rule create --proto tcp --dst-port 22 default
```

In the standard DevStack installation there are two security groups with the name "default". In this case it is necessary to use the project and security group IDs to identifythe correct group to update.
You can get the IDs using the following:
```bash
openstack project list
openstack security group list
```

Once obtained, insert the values as per the below:
```bash
openstack security group rule create --project <project_id> --proto icmp --dst-port 0 <default security_group_id>
openstack security group rule create --project <project_id> --proto tcp --dst-port 22 <default security_group_id>
```

## Create Router
```bash
openstack router create --project admin --enable public
openstack router add subnet public shared-subnet
openstack router set --enable-snat --external-gateway public public
openstack router show public
```

## Add DNS to Network
```bash
openstack subnet set --dns-nameserver 8.8.8.8  --dns-nameserver 8.8.4.4 --dns-nameserver 1.1.1.1 shared-subnet
```

## Manual Image Upload (Optional)
This is an optional step in case you want to upload more images to OpenStack.
Debian 10 and Debian 11 base images should have been uploaded already when you ran `stack.sh`, as we included it in `local.conf` above.
```bash
wget https://cdimage.debian.org/cdimage/cloud/bullseye/latest/debian-11-generic-amd64.qcow2

openstack image create \
	--container-format bare \
	--disk-format qcow2 \
	--file  debian-11-generic-amd64.qcow2 \
	debian-11-openstack-amd64
```

## Create SSH Key
!!! tip
    Creating the SSH key will make it easy to enter the VM for debugging a failed build
```bash
openstack keypair create --public-key ~/.ssh/id_rsa.pub packer-build
```

## Build Packer Image
!!! warning
    Note, the value for `openstack_networks` must be the private network (named "shared" or "private" in the default DevStack setup), and not the public one.

In order to build KX.AS.CODE, you can now run the following commands.

### KX-Main
```bash
packer build -force -only kx.as.code-main-openstack \
  -var compute_engine_build=true \
  -var hostname=kx-main \
  -var domain=kx-as-code.local \
  -var version=0.8.6 \
  -var kube_version=1.21.3-00 \
  -var vm_user=kx.hero \
  -var vm_password=L3arnandshare \
  -var git_source_url=https://github.com/Accenture/kx.as.code.git \
  -var git_source_branch=main \  # KX.AS.CODE branch to check out inside VM
  -var git_source_user=******** \ # optional, not needed for public Git repository
  -var git_source_token=******* \  # optional, not needed for public Git repository
  -var base_image_ssh_user=debian \
  -var openstack_auth_url=http://192.200.76.201/identity/ \
  -var openstack_user=admin \
  -var openstack_password=<enter OpenStack password set during OpenStack install> \
  -var openstack_region=RegionOne \
  -var openstack_networks=<enter private network ID here> \
  -var openstack_floating_ip_network=public \  # change if your public network with a gateway is named differently
  -var openstack_source_image=<add source image ID for Debian 11 here> \
  -var openstack_flavor=m1.medium \
  -var openstack_security_groups=default \
  -var ssh_keypair_name=packer-build \
  ./kx-main-cloud-profiles.json
```
### KX-Node
```bash
packer build -force -only kx.as.code-node-openstack \
  -var compute_engine_build=true \
  -var hostname=kx-node \
  -var domain=kx-as-code.local \
  -var version=0.8.6 \
  -var kube_version=1.21.3-00 \
  -var vm_user=kx.hero \
  -var vm_password=L3arnandshare \
  -var git_source_url=https://github.com/Accenture/kx.as.code.git \
  -var git_source_branch=main \  # KX.AS.CODE branch to check out inside VM
  -var git_source_user=******** \ # optional, not needed for public Git repository
  -var git_source_token=******* \  # optional, not needed for public Git repository
  -var base_image_ssh_user=debian \
  -var openstack_auth_url=http://192.200.76.201/identity/ \
  -var openstack_user=admin \
  -var openstack_password=<enter OpenStack password set during OpenStack install> \
  -var openstack_region=RegionOne \
  -var openstack_networks=<enter private network ID here> \
  -var openstack_floating_ip_network=public \  # change if your public network with a gateway is named differently
  -var openstack_source_image=<add source image ID for Debian 11 here> \
  -var openstack_flavor=m1.medium \
  -var openstack_security_groups=default \
  -var ssh_keypair_name=packer-build \
  ./kx-node-cloud-profiles.json
  
## Restarting OpenStack in case of issues
```bash
# Optionally restart network if connectivity issues start appearing, such as DNS timeout etc
sudo systemctl restart systemd-networkd

# Restarting DevStack
sudo systemctl restart devstack@*
```

## Resetting your OpenStack environment
If you have any issues with your OpenStack installation (this could happen after a reboot for example), then you can do the following to reset it.
```bash
sudo su stack
cd /opt/stack/devstack
./clean.sh
./unstack.sh
sudo rm -rf /run/ovn
sudo reboot
```
Once you have completed the steps and rebooted, just go back to `/opt/stack/devstack` as the stack user and run `./stack.sh` again. Afterwards you will again need to run the post steps again, such as reinitializing the volume file, updating `nova.conf` and applying the increased limits again etc.
You can either do it manually by repeating the steps after `stack.sh` above, or using the script below.

```bash
#!/bin/bash

# Add cinder options to prevent provisioning timeout (not really working)
if [[ $(cat /etc/nova/nova.conf | grep -c "block_device_allocate_retries") -le 0 ]]; then
        sudo sed -i '/^\[DEFAULT\]/a block_device_allocate_retries=600\nblock_device_allocate_retries_interval=3' /etc/nova/nova.conf
else
        echo "No change to nova.conf needed"
fi

# Setup virtual volume (not needed if using an LVM with physical volumes)
sudo rm -f /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
sudo truncate -s 1500G /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
sudo losetup -f /opt/stack/data/stack-volumes-lvmdriver-1-backing-file
loopDevice=$(basename $(sudo losetup -f --show /opt/stack/data/stack-volumes-lvmdriver-1-backing-file))
sudo vgcreate stack-volumes-lvmdriver-1 /dev/${loopDevice}

# Correct loopback device in lvm.conf
sudo sed -i 's;\/loop.*[0-9]\/;\/'${loopDevice}'\/;g' /etc/lvm/lvm.conf

# Restart OpenStack
sudo systemctl restart devstack@*

# Get OpenStack token
. /opt/stack/devstack/openrc admin
export OS_AUTH_TOKEN=$(openstack token issue -c id -f value)

# Check if OpenStack volume service is now up
openstack volume service list

# Set new limits
openstack quota set --volumes 30 admin
openstack quota set --gigabytes 1700 admin
openstack quota set --snapshots 30 admin

# Get project and security group ids
openstack project list
openstack security group list
projectId=$(openstack project show admin -f json | jq -r '.id')
securityGroupId=$(openstack security group list --project ${projectId} -f json | jq -r '.[] | select(.Name=="default") | .ID')

# Add rules to admin project's default security group
openstack security group rule create --project ${projectId} --proto icmp --dst-port 0 ${securityGroupId}
openstack security group rule create --project ${projectId} --proto tcp --dst-port 22 ${securityGroupId}

# Setup router
openstack router create --project admin --enable public
openstack router add subnet public shared-subnet
openstack router set --enable-snat --external-gateway public public
openstack router show public

# Configure DNS
openstack subnet set --dns-nameserver 8.8.8.8  --dns-nameserver 8.8.4.4 --dns-nameserver 1.1.1.1 shared-subnet
```

