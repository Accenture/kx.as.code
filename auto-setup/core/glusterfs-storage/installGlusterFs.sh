#!/bin/bash
set -euox pipefail

partitionExists=""
glusterFsDrive=""

# Do not install GlusterFS if standalone mode = true, as in this case, the vagrantfile does not mount the associated hard disk
if [[ ${standaloneMode} == "false" ]]; then

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
/usr/bin/sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial

# Use disk name if supplied in profile-config.json
export glusterFsDiskName=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.glusterFsDiskName')

# Get GlusterFS volume size from profile-config.json
export glusterFsDiskSize=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.glusterFsDiskSize')

# Install NVME CLI if needed, for example, for AWS
nvme_cli_needed=$(df -h | grep "nvme" || true)
if [[ -n ${nvme_cli_needed} ]]; then
    /usr/bin/sudo apt install -y nvme-cli lvm2
fi

# If disk name not supplied in config, try to work out which free disk to use (by checking un-partitioned disk size against requested size in profile-config.json
if [[ -z ${glusterFsDiskName} ]] || [[ "${glusterFsDiskName}" == "null" ]]; then
  log_info "Drive for GlusterFs not defined in profile-config.json. Attempting to automatically detect the correct drive."
  if [[ -f /usr/share/kx.as.code/.config/glusterFsDrive ]]; then
    glusterFsDrive=$(cat /usr/share/kx.as.code/.config/glusterFsDrive)
  else
    glusterFsDrive=$(lsblk -o NAME,FSTYPE,SIZE -dsn -J | jq -r '.[] | .[] | select(.fstype==null) | select(.size=="'$((${glusterFsDiskSize}+1))'G") | .name' || true)
    echo "${glusterFsDrive}" | /usr/bin/sudo tee /usr/share/kx.as.code/.config/localStorageDrive

  fi
  partitionExists=$(lsblk -o NAME,FSTYPE,SIZE -J | jq -r '.blockdevices[] | select(.name=="'${glusterFsDrive}'") | .children[]? | select(.name=="'${glusterFsDrive}'1") | .name')
else
  log_info "Setting drive for GlusterFs to ${glusterFsDiskName} as per profile-config.json"
  echo "${glusterFsDiskName}" | /usr/bin/sudo tee /usr/share/kx.as.code/.config/glusterFsDrive
  glusterFsDrive=${glusterFsDiskName}
fi

# Prepare disk
/usr/bin/sudo wipefs -a -t dos -f /dev/${glusterFsDrive}
/usr/bin/sudo fdisk -l /dev/${glusterFsDrive}
/usr/bin/sudo mkfs.xfs /dev/${glusterFsDrive}

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

log_debug "Initializing kadalu storage pool with - kubectl kadalu storage-add storage-pool-1 --device kx-main1:/dev/${glusterFsDrive} --script-mode"
/usr/bin/sudo kubectl kadalu storage-add storage-pool-1 --device kx-main1:/dev/${glusterFsDrive} --script-mode

# Wait for Kubernetest statefulset to become available
waitForKubernetesResource "server-storage-pool-1-0" "statefulset" "kadalu"

# Edit default statefulset to allow it to be schedule on master kx-main1, despite the node taint
kubectl get statefulset server-storage-pool-1-0 -n kadalu -o yaml | /usr/bin/sudo tee ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml
if [[ -f ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml ]]; then
  /usr/bin/sudo sed -i -e '/^                values:/{:a; N; /\n                - kx-main1/!ba; a \      tolerations:\n        - key: node-role.kubernetes.io/master\n          operator: Exists\n          effect: NoSchedule' -e '}' ${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml
  
  # Validate and apply the updated config-map
  kubernetesApplyYamlFile "${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml" "kadalu"
else
  log_error "${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml does not exist after exporting statefulset with kubectl"
  exit 1
fi

# Check storage pool created correctly
if [[ -z $( kubectl kadalu storage-list --name storage-pool-1 --detail | grep "/dev/${glusterFsDrive}" ) ]]; then
  log_error "storage-pool-1 seems not to be registered in kadalu... exiting with RC=1"
  exit 1
else
  log_debug "$( kubectl kadalu storage-list --name storage-pool-1 --detail )"
fi

# Wait for storage class "local-path" to be available by K3s before proceeeding to update it
waitForKubernetesResource "kadalu.storage-pool-1" "storageclass"

# Make kadalu.storage-pool-1 storage class Kubernetes NOT default (switched default to local storage)
kubectl patch storageclass kadalu.storage-pool-1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Remove storage pool server if it already exists, so a new one can be provisioned after updating the statefulset above
kubectl delete pods -l "app.kubernetes.io/component=server" -n kadalu

fi