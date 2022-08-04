#!/bin/bash -x
set -euo pipefail

# Install AWS CLI
mkdir ${INSTALLATION_WORKSPACE}/aws
cd ${INSTALLATION_WORKSPACE}/aws

if [[ -n $( uname -a | grep "aarch64") ]]; then
  # Download URL for ARM64 CPU architecture
  AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
  AWS_CLI_CHECKSUM="2a4b5067df0fa46bba9e9207c9ec477c75de62914a0b08712bfbc6e550ed873c"
else
  # Download URL for X86_64 CPU architecture
  AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  AWS_CLI_CHECKSUM="9479564814b37c1cab5af82ef414ee1d1d5cf32562a417b27f37dd3be3b1103f"
fi

curl ${AWS_CLI_URL} -o "awscliv2.zip"

AWS_CLI_FILE=awscliv2.zip
echo "${AWS_CLI_CHECKSUM} ${AWS_CLI_FILE}" | sha256sum --check

unzip awscliv2.zip
sudo ./aws/install
