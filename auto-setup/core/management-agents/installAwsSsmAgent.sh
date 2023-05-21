#!/bin/bash
set -euo pipefail

# Install AWS SSM Agent if running in AWS
deployedAwsAmiImage=$(cat ${profileConfigJsonPath} | jq -r '.vm_properties.kx_main_ami_id')
if [[ -n "${deployedAwsAmiImage}" ]] && [[ "${deployedAwsAmiImage}" != "null" ]]; then
  mkdir ${installationWorkspace}/aws-ssm
  curl -o ${installationWorkspace}/aws-ssm/amazon-ssm-agent.deb https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
  /usr/bin/sudo dpkg -i ${installationWorkspace}/aws-ssm/amazon-ssm-agent.deb
  /usr/bin/sudo systemctl enable amazon-ssm-agent
fi
