#!/bin/bash -x
set -euo pipefail

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
/usr/bin/sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial

# Get number of local volumes to pre-provision
export number1gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.fifty_gb')

# Calculate total needed disk size (should match the value the VM was provisioned with)
export localKubeVolumesDiskSize=$(((number1gbVolumes * 1) + (number5gbVolumes * 5) + (number10gbVolumes * 10) + (number30gbVolumes * 30) + (number50gbVolumes * 50) + 1))

# Install NVME CLI if needed, for example, for AWS
nvme_cli_needed=$(df -h | grep "nvme" || true)
if [[ -n ${nvme_cli_needed} ]]; then
    /usr/bin/sudo apt install -y nvme-cli lvm2
fi

# Determine Drive B (Local K8s Volumes Storage)
for i in {{1..30}}; do
  driveB=$(lsblk -o NAME,FSTYPE,SIZE -dsn -J | jq -r '.[] | .[] | select(.fstype==null) | select(.size=="'${localKubeVolumesDiskSize}'G") | .name' || true)
  if [[ -z ${driveB} ]]; then
    log_info "Drive for local volumes not yet available. Trying a maximum of 30 times. Attempt ${i}"
    sleep 15
  else
    log_info "Drive for local volumes (${driveB}) now available after attempt ${i} of 30"
    break
  fi
done
formatted=""
if [[ ! -f /usr/share/kx.as.code/.config/driveB ]]; then
    echo "${driveB}" | /usr/bin/sudo tee /usr/share/kx.as.code/.config/driveB
    cat /usr/share/kx.as.code/.config/driveB
else
    driveB=$(cat /usr/share/kx.as.code/.config/driveB)
    formatted=true
fi
if [[ -z ${driveB} ]]; then
  log_error "Error finding mounted drive for setting up the K8s local storage service. Quitting script and sending task to failure queue"
  return 1
fi
# Check logical partitions
/usr/bin/sudo lvs
/usr/bin/sudo df -hT
/usr/bin/sudo lsblk

# Create full partition on /dev/${driveB}
if [[ -z ${formatted} ]]; then
    echo 'type=83' | /usr/bin/sudo sfdisk /dev/${driveB}
    for i in {1..5}; do
      driveB_Partition=$(lsblk -o NAME,FSTYPE,SIZE -J | jq -r '.[] | .[]  | select(.name=="'${driveB}'") | .children[].name' || true)
      if [[ -n ${driveB_Partition} ]]; then
        log_info "Disk ${driveB} partitioned successfully -> ${driveB_Partition}"
        break
      else
        log_warn "Disk partition could not be found on ${driveB} (attempt ${i}), trying again"
        sleep 5
      fi
    done
    /usr/bin/sudo pvcreate /dev/${driveB_Partition}
    /usr/bin/sudo vgcreate k8s_local_vol_group /dev/${driveB_Partition}
fi

BASE_K8S_LOCAL_VOLUMES_DIR=/mnt/k8s_local_volumes

create_volumes() {
    if [[ ${2} -ne 0 ]]; then
        for i in $(eval echo "{1..$2}"); do
            if [[ -z $(lsblk -J | jq -r ' .. .name? // empty | select(test("k8s_local_vol_group-k8s_'${1}'_local_k8s_volume_'${i}'"))' || true) ]]; then
                for j in {1..5}; do
                  # Added loop, as sometimes two tries are required
                  /usr/bin/sudo lvcreate -L $(( ${1} * 1024))M -n k8s_${1}_local_k8s_volume_${i} k8s_local_vol_group
                  /usr/bin/sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}
                  /usr/bin/sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}
                  errorOutput=$(/usr/bin/sudo mount /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i} 2>&1 >/dev/null || true)
                  if [[ -z "${errorOutput}" ]]; then
                    log_info "Successfully mounted /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} to ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}"
                    break
                  else
                    log_error "Mount error after mount attempt ${j}!: ${errorOutput}"
                  fi
                done
                # Don't add entry to /etc/fstab if the volumes was not created, possibly due to running out of diskspace
                if [[ -L /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]] && [[ -e /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]]; then
                    entryAlreadyExists=$(cat /etc/fstab | grep "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}" || true)
                    # Don't add entry to /etc/fstab if it already exists
                    if [[ -z ${entryAlreadyExists} ]]; then
                        /usr/bin/sudo echo '/dev/k8s_local_vol_group/k8s_'${1}'_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_'${1}'_local_k8s_volume_'${i}' xfs defaults 0 0' | /usr/bin/sudo tee -a /etc/fstab
                    fi
                else
                    echo "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} does not exist. Not adding to /etc/fstab. Possible reason is that there was not enough space left on the drive to create it"
                fi
            fi
        done
    fi
}

create_volumes "1" ${number1gbVolumes}
create_volumes "5" ${number5gbVolumes}
create_volumes "10" ${number10gbVolumes}
create_volumes "30" ${number30gbVolumes}
create_volumes "50" ${number50gbVolumes}

# Check logical partitions
/usr/bin/sudo lvs
/usr/bin/sudo df -hT
/usr/bin/sudo lsblk

# Checkout Storage Provisioner
if [[ -d ./sig-storage-local-static-provisioner ]]; then
    rm -rf ./sig-storage-local-static-provisioner
fi
git clone --depth=1 https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner.git
cd sig-storage-local-static-provisioner

# Replace placeholders with environment variables from metadata.json
echo "PATH: $PATH"
envhandlebars < ${installComponentDirectory}/values.yaml > ${installationWorkspace}/${componentName}_values.yaml

# Generate install YAML file via Helm
helm template -f ${installationWorkspace}/${componentName}_values.yaml local-volume-provisioner --namespace ${namespace} ./helm/provisioner > ${installationWorkspace}/local-volume-provisioner.generated.yaml

# Apply YAML file
kubectl apply -f ${installationWorkspace}/local-volume-provisioner.generated.yaml

# Provision Storage Class
echo '''
# Only create this for K8s 1.9+
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
# Supported policies: Delete, Retain
reclaimPolicy: Delete
''' | kubectl apply -f -

# Make local storage class default
kubectl patch storageclass local-storage-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
