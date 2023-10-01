#!/bin/bash

# Download Awssamcli
downloadFile "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" \
  "${awssamcliChecksum}" \
  "${installationWorkspace}/aws-sam-cli-linux-x86_64.zip" && log_info "Return code received after downloading aws-sam-cli-linux-x86_64.zip is $?"

# Install Awssamcli
/usr/bin/sudo unzip -o ${installationWorkspace}/aws-sam-cli-linux-x86_64.zip -d ${installationWorkspace}/awssam
${installationWorkspace}/awssam/install

# Check SAM is working and available on the path
sam --version