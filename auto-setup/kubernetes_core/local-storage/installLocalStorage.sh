#!/bin/bash

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial
nvme_cli_needed=$(df -h | grep "nvme")
if [[ -n ${nvme_cli_needed} ]]; then
  # For AWS
  sudo apt install -y nvme-cli lvm2
  export partition="p1"
else
  export partition="1"
fi

drives=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep disk | awk {'print $1'})
for drive in ${drives}
do
  partitions=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep ${drive} | grep part)
  if [[ -z ${partitions} ]]; then
    export driveB="${drive}"
    break
  fi
done

echo "${driveB}" | sudo tee /home/${vmUser}/.config/kx.as.code/driveB
cat /home/${vmUser}/.config/kx.as.code/driveB

# Get number of local volumes to pre-provision
export number1gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.one_gb')
export number5gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.five_gb')
export number10gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.ten_gb')
export number30gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.thirty_gb')
export number50gbVolumes=$(cat ${installationWorkspace}/autoSetup.json | jq -r '.config.local_volumes.fifty_gb')

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

# Deploy local volume provisioner. To be used for databases etc
wget https://raw.githubusercontent.com/kubernetes-sigs/sig-storage-local-static-provisioner/master/deployment/kubernetes/example/default_example_provisioner_generated.yaml -O ${installationWorkspace}/local_storage_provisioner_install.yaml
sed -i 's/\/mnt\/fast-disks/\/mnt\/k8s_local_volumes/g' ${installationWorkspace}/local_storage_provisioner_install.yaml
sed -i 's/ext4/xfs/g' ${installationWorkspace}/local_storage_provisioner_install.yaml
sed -i 's/fast-disks/local-storage/g' ${installationWorkspace}/local_storage_provisioner_install.yaml
sed -i 's/namespace: default/namespace: kube-system/g' ${installationWorkspace}/local_storage_provisioner_install.yaml
kubectl apply -f ${installationWorkspace}/local_storage_provisioner_install.yaml -n kube-system

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