#!/bin/bash

# Download Awscli
downloadFile "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  "${awscliChecksum}" \
  "${installationWorkspace}/awscli-exe-linux-x86_64.zip" && log_info "Return code received after downloading awscli-exe-linux-x86_64.zip is $?"

# Install Awscli
/usr/bin/sudo unzip -o ${installationWorkspace}/awscli-exe-linux-x86_64.zip -d ${installationWorkspace}
${installationWorkspace}/aws/install

# Rename /usr/bin/aws so new version takes effect
if [[ -f /usr/bin/aws ]]; then
  /usr/bin/sudo mv /usr/bin/aws /usr/bin/aws-old
fi

# Check AWS is working and available on the path
aws --version