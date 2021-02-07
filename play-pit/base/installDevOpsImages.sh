#!/bin/bash -eux

. /etc/environment
export VM_USER=$vmUser

# Build KX.AS.CODE "Docs" Image
cd /home/$VM_USER/Documents/kx.as.code_docs
. ./build.sh

# Install KX.AS.CODE Docs Image
cd /home/$VM_USER/Documents/kx.as.code_docs/kubernetes
. ./install.sh

# Build KX.AS.CODE "TechRadar" Image
cd /home/$VM_USER/Documents/kx.as.code_techradar
. ./build.sh

# Install DevOps Tech Radar Image
cd /home/$VM_USER/Documents/kx.as.code_techradar/kubernetes
. ./install.sh

# Cleanup after Docker Build
sudo docker rmi -f $(sudo docker images python -q)
sudo docker rmi -f $(sudo docker images nginx --format '{{.Repository}}:{{.Tag}}')
sudo docker rmi -f $(sudo docker images -f "dangling=true" -q | tr "\n" " ")
