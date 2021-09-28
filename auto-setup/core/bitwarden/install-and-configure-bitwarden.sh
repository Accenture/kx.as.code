#!/bin/bash -x
set -euo pipefail

export bitwardenDataDir=/opt/bitwarden/bwdata
# Create Bitwarden user
sudo id -u bitwarden &>/dev/null || adduser bitwarden

# Add groups to Bitwarden user
sudo usermod -aG docker bitwarden

# Create Bitwarden data directrory
sudo mkdir -p ${bitwardenDataDir}/ssl/${componentName}.${baseDomain}

# Copy self signed certificates to Bitwarden data directory
sudo cp ${installationWorkspace}/kx-certs/* ${bitwardenDataDir}/ssl/${componentName}.${baseDomain}

# Create Bitwarden config file from template
ensubst < config_template.yml > ${bitwardenDataDir}/config.yml

# Correct directory permissions
sudo chmod -R 700 /opt/bitwarden
sudo chown -R bitwarden:bitwarden /opt/bitwarden

# Download Bitwarden install script
curl -Lso bitwarden.sh https://go.btwrdn.co/bw-sh \
    && chmod 700 bitwarden.sh

# Execute Bitwarden install script
