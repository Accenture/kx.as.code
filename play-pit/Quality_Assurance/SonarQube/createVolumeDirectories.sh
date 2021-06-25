#!/bin/bash -x
set -euo pipefail

# Create directories
mkdir -p /home/$VM_USER/KX_Data/sonarqube/db
mkdir -p /home/$VM_USER/KX_Data/sonarqube/app

# Correct ownership
sudo chmod -R 777 /home/$VM_USER/KX_Data/sonarqube
sudo chown -R 1000:1000 /home/$VM_USER/KX_Data/sonarqube
