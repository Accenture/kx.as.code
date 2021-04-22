#!/bin/bash

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial

# Get number of local volumes to pre-provision
export number1gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.local_volumes.fifty_gb')

# Calculate total needed disk size (should match the value the VM was provisioned with)
export localKubeVolumesDiskSize=$(( ( ${number1gbVolumes} * 1 ) + ( ${number5gbVolumes} * 5 ) + ( ${number10gbVolumes} * 10 ) + ( ${number30gbVolumes} * 30 ) + ( ${number50gbVolumes} * 50 ) + 1 ))

nvme_cli_needed=$(df -h | grep "nvme")
if [[ -n ${nvme_cli_needed} ]]; then
  # For AWS
  sudo apt install -y nvme-cli lvm2
fi

# Determine Drive B (Local K8s Volumes Storage)
driveB=$(lsblk -o NAME,FSTYPE,SIZE -dsn -J | jq -r '.[] | .[] | select(.fstype==null) | select(.size=="'${localKubeVolumesDiskSize}'G") | .name')

#TODO Cleanup after confirming change
#nvme_cli_needed=$(df -h | grep "nvme")
#if [[ -n ${nvme_cli_needed} ]]; then
#  # For AWS
#  sudo apt install -y nvme-cli lvm2
#  export partition="p1"
#else
#  export partition="1"
#fi

#drives=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep disk | awk {'print $1'})
#for drive in ${drives}
#do
#  partitions=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep ${drive} | grep part)
#  if [[ -z ${partitions} ]]; then
#    export driveB="${drive}"
#    break
#  fi
#done

echo "${driveB}" | sudo tee /usr/share/kx.as.code/.config/driveB
cat /usr/share/kx.as.code/.config/driveB

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

# Create full partition on /dev/${driveB}
echo 'type=83' | sudo sfdisk /dev/${driveB}

sudo pvcreate /dev/${driveB}${partition}
sudo vgcreate k8s_local_vol_group /dev/${driveB}${partition}

BASE_K8S_LOCAL_VOLUMES_DIR=/mnt/k8s_local_volumes

create_volumes() {
  if [[ ${2} -ne 0 ]]; then
    for i in $(eval echo "{1..$2}")
    do
        sudo lvcreate -L ${1} -n k8s_${1}_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_${1}_local_k8s_volume_${i}
        # Don't add entry to /etc/fstab if the volumes was not created, possibly due to running out of diskspace
        if [[ -L /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]] && [[ -e /dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} ]]; then
          entryAlreadyExists=$(cat /etc/fstab | grep "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i}")
          # Don't add entry to /etc/fstab if it already exists
          if [[ -z ${entryAlreadyExists} ]]; then
            sudo echo '/dev/k8s_local_vol_group/k8s_'${1}'_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_'${1}'_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
          fi
        else
          echo "/dev/k8s_local_vol_group/k8s_${1}_local_k8s_volume_${i} does not exist. Not adding to /etc/fstab. Possible reason is that there was not enough space left on the drive to create it"
        fi
    done
  fi
}

create_volumes "1G" ${number1gbVolumes}
create_volumes "5G" ${number5gbVolumes}
create_volumes "10G" ${number10gbVolumes}
create_volumes "30G" ${number30gbVolumes}
create_volumes "50G" ${number50gbVolumes}

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

# Checkout Storage Provisioner
git clone --depth=1 https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner.git
cd sig-storage-local-static-provisioner

# Replace placeholders with environment variables from metadata.json
envhandlebars < ${installComponentDirectory}/values.yaml > ${installationWorkspace}/${componentName}_values.yaml

# Generate install YAML file via Helm
helm template -f ${installationWorkspace}/${componentName}_values.yaml local-volume-provisioner --namespace ${namespace} ./helm/provisioner > ${installationWorkspace}/local-volume-provisioner.generated.yaml

# Apply YAML file
kubectl create -f ${installationWorkspace}/local-volume-provisioner.generated.yaml

# Provision Storage Class
echo '''
# Only create this for K8s 1.9+
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
# Supported policies: Delete, Retain
reclaimPolicy: Delete
''' | kubectl apply -f -

# Make local storage class default
kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
