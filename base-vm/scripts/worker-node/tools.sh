#!/bin/bash -eux

# Register KX-Main node as Netdata Registry
echo """
[registry]
    enabled = no
    registry to announce = http://kx-main:19999
""" | sudo tee -a /etc/netdata/netdata.conf

# Update Debian repositories as default is old
wget -O - https://download.gluster.org/pub/gluster/glusterfs/8/rsa.pub | sudo apt-key add -
echo deb [arch=amd64] https://download.gluster.org/pub/gluster/glusterfs/8/LATEST/Debian/buster/amd64/apt buster main | sudo tee /etc/apt/sources.list.d/gluster.list
sudo apt update
sudo apt install -y glusterfs-client