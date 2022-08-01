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

# Prepare disk
/usr/bin/sudo wipefs -a -t dos -f /dev/${driveC}
/usr/bin/sudofdisk -l /dev/${driveC}
/usr/bin/sudo mkfs.xfs /dev/${driveC}

# Install GlusterFs (9.2-1) server from Debian Bullseye distribution
/usr/bin/sudo apt update
/usr/bin/sudo apt install -y glusterfs-server
/usr/bin/sudo systemctl enable --now glusterd

# Install Kadalu GlusterFS Manager
curl -fsSL https://github.com/kadalu/kadalu/releases/latest/download/install.sh | /usr/bin/sudo bash -x

# Check if Kadalu installed correctly
if [[ ! -f /usr/bin/kubectl-kadalu ]]; then
  log_error "/usr/bin/kubectl-kadalu not found. Something must have gone wrong during the install"
  exit 1
fi

# Install Kadalu Kubernetes plugin
log_debug "$(kubectl-kadalu version)"
kubectl kadalu install --type=kubernetes

log_debug "Initializing kadalu storage pool with - kubectl kadalu storage-add storage-pool-1 --device kx-main1:/dev/${driveC} --script-mode"
/usr/bin/sudo kubectl kadalu storage-add storage-pool-1 --device kx-main1:/dev/${driveC} --script-mode

# Wait for Kubernetest statefulset to become available
waitForKubernetesResource "server-storage-pool-1-0" "statefulset" "kadalu"

# Edit default statefulset to allow it to be schedule on master kx-main1, despite the node taint
kubectl get statefulset server-storage-pool-1-0 -n kadalu -o yaml | /usr/bin/sudo tee ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml
if [[ -f ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml ]]; then
  /usr/bin/sudo sed -i -e '/^                values:/{:a; N; /\n                - kx-main1/!ba; a \      tolerations:\n        - key: node-role.kubernetes.io/master\n          operator: Exists\n          effect: NoSchedule' -e '}' ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml
  kubectl apply -f ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml -n kadalu
else
  log_error "${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml does not exist after exporting statefulset with kubectl"
  exit 1
fi

# Check storage pool created correctly
if [[ -z $( kubectl kadalu storage-list --name storage-pool-1 --detail | grep "/dev/${driveC}" ) ]]; then
  log_error "storage-pool-1 seems not to be registered in kadalu... exiting with RC=1"
  exit 1
else
  log_debug "$( kubectl kadalu storage-list --name storage-pool-1 --detail )"
fi

# Wait for storage class "local-path" to be available by K3s before proceeeding to update it
waitForKubernetesResource "kadalu.storage-pool-1" "storageclass"

# Make kadalu.storage-pool-1 storage class Kubernetes NOT default (switched default to local storage)
kubectl patch storageclass kadalu.storage-pool-1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

fi