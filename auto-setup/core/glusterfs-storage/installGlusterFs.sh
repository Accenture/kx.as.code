#!/bin/bash
set -euo pipefail

# Do not install GlusterFS if standalone mode = true, as in this case, the vagrantfile does not mount the associated hard disk
if [[ ${standaloneMode} == "false" ]]; then

# Get GlusterFS volume size from profile-config.json
export glusterFsDiskSize=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.glusterFsDiskSize')

# Install NVME CLI if needed, for example, for AWS
nvme_cli_needed=$(df -h | grep "nvme" || true)
if [[ -n ${nvme_cli_needed} ]]; then
    /usr/bin/sudo apt install -y nvme-cli lvm2
fi

partitionC1Exists=$(lsblk -o NAME,FSTYPE,SIZE -J | jq -r '.blockdevices[] | select(.name=="sdc") | .children[] | select(.name=="sdc1") | .name')

if [[ "${partitionC1Exists}" != "sdc1" ]]; then

  # Determine Drive C (GlusterFS) - Relevant for KX-Main1 only
  for i in {{1..30}}; do
    driveC=$(lsblk -o NAME,FSTYPE,SIZE -dsn -J | jq -r '.[] | .[] | select(.fstype==null) | select(.size=="'$((${glusterFsDiskSize}+1))'G") | .name' || true)
    if [[ -z ${driveC} ]]; then
      log_info "Drive for glusterfs not yet available. Trying a maximum of 30 times. Attempt ${i}"
      sleep 15
    else
      log_info "Drive for glusterfs (${driveC}) now available after attempt ${i} of 30"
      break
    fi
  done
  formatted=""
  if [[ ! -f /usr/share/kx.as.code/.config/driveC ]]; then
      echo "${driveC}" | /usr/bin/sudo tee /usr/share/kx.as.code/.config/driveC
      cat /usr/share/kx.as.code/.config/driveC
  else
      driveC=$(cat /usr/share/kx.as.code/.config/driveC)
      formatted=true
  fi
  if [[ -z ${driveC} ]]; then
    log_error "Error finding mounted drive for setting up glusterfs. Quitting script and sending task to failure queue"
    return 1
  fi

fi

# Install GlusterFs (9.2-1) server from Debian Bullseye distribution
/usr/bin/sudo apt update
/usr/bin/sudo apt install -y glusterfs-server
/usr/bin/sudo /usr/bin/sudo systemctl enable --now glusterd

# Install Kadalu GlusterFS Manager
curl -fsSL https://github.com/kadalu/kadalu/releases/latest/download/install.sh | sudo bash -x
kubectl-kadalu version
kubectl kadalu install --type=kubernetes
kubectl kadalu storage-add storage-pool-1 --device kx-main1:/dev/${driveC}

# Make kadalu.storage-pool-1 storage class Kubernetes NOT default (switched default to local storage)
kubectl patch storageclass kadalu.storage-pool-1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

fi