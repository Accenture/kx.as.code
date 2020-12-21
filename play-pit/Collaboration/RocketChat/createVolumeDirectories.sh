#!/bin/bash -eux

# Create directories
mkdir -p /home/$VM_USER/KX_Data/rocketchat/db
mkdir -p /home/$VM_USER/KX_Data/rocketchat/app

# Correct ownership
sudo chown -R 1001:0 /home/$VM_USER/KX_Data/rocketchat/db
sudo chown -R 1001:0 /home/$VM_USER/KX_Data/rocketchat/app
