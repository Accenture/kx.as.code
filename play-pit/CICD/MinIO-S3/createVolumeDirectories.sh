#!/bin/bash -eux

# Create directories
mkdir -p /home/$VM_USER/KX_Data/minio_s3

# Correct ownership
sudo chown -R 1000:1000 /home/$VM_USER/KX_Data/minio_s3
