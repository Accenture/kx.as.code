#!/bin/bash

# Install nvme-cli if running on host with NVMe block devices (for example on AWS with EBS)
sudo lsblk -i -o kname,mountpoint,fstype,size,maj:min,name,state,rm,rota,ro,type,label,model,serial
nvme_cli_needed=$(df -h | grep "nvme")
if [[ -n "nvme_cli_needed" ]]; then
  # For AWS
  sudo apt install -y nvme-cli lvm2
  drives=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep disk | awk {'print $1'})
  for drive in ${drives}
  do
    partitions=$(lsblk -i -o kname,mountpoint,fstype,size,type | grep ${drive} | grep part)
    if [[ -z ${partitions} ]]; then
      export driveB="${drive}"
      export partition="p1"
      break
    fi
  done
else
  # For VirtualBox, VNWare etc
  export driveB="sdb"
  export partition="1"
fi

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

# Pre-create 1G volumes to be used by the K8s local-volume-provisioner
if [[ ${number1gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number1gbVolumes}")
    do
        sudo lvcreate -L 1G -n k8s_1g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_1g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_1g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_1g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Pre-create 5G volumes to be used by the K8s local-volume-provisioner
if [[ ${number5gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number5gbVolumes}")
    do
        sudo lvcreate -L 5G -n k8s_5g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_5g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_5g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_5g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Pre-create 10G volumes to be used by the K8s local-volume-provisioner
if [[ ${number10gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number10gbVolumes}")
    do
        sudo lvcreate -L 10G -n k8s_10g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_10g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_10g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_10g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

# Pre-create 30G volumes to be used by the K8s local-volume-provisioner
if [[ ${number30gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number30gbVolumes}")
    do
        sudo lvcreate -L 50G -n k8s_50g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_50g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi


# Pre-create 50G volumes to be used by the K8s local-volume-provisioner
if [[ ${number50gbVolumes} -ne 0 ]]; then
    for i in $(eval echo "{1..$number50gbVolumes}")
    do
        sudo lvcreate -L 50G -n k8s_50g_local_k8s_volume_${i} k8s_local_vol_group
        sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i}
        sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo mount /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
        sudo echo '/dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_50g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
    done
fi

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