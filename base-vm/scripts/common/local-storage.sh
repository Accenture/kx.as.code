#!/bin/bash -eux
set -o pipefail

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk

# Create full partition on /dev/sdb
echo 'type=83' | sudo sfdisk /dev/sdb

sudo pvcreate /dev/sdb1
sudo vgcreate k8s_local_vol_group /dev/sdb1

BASE_K8S_LOCAL_VOLUMES_DIR=/mnt/k8s_local_volumes

# Pre-create 1G volumes to be used by the K8s local-volume-provisioner
for i in {1..10}
do
    sudo lvcreate -L 1G -n k8s_1g_local_k8s_volume_${i} k8s_local_vol_group
    sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_${i}
    sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_1g_local_k8s_volume_${i}
    sudo mount /dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_1g_local_k8s_volume_${i}
    sudo echo '/dev/k8s_local_vol_group/k8s_1g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_1g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
done

# Pre-create 5G volumes to be used by the K8s local-volume-provisioner
for i in {1..8}
do
    sudo lvcreate -L 5G -n k8s_5g_local_k8s_volume_${i} k8s_local_vol_group
    sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_${i}
    sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_5g_local_k8s_volume_${i}
    sudo mount /dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_5g_local_k8s_volume_${i}
    sudo echo '/dev/k8s_local_vol_group/k8s_5g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_5g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
done

# Pre-create 10G volumes to be used by the K8s local-volume-provisioner
for i in {1..5}
do
    sudo lvcreate -L 10G -n k8s_10g_local_k8s_volume_${i} k8s_local_vol_group
    sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_${i}
    sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_10g_local_k8s_volume_${i}
    sudo mount /dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_10g_local_k8s_volume_${i}
    sudo echo '/dev/k8s_local_vol_group/k8s_10g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_10g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
done

### TODO - read config from autoSetup.json rather than hardcoding the number of volumes (above and below)

# Pre-create 30G volumes to be used by the K8s local-volume-provisioner
#for i in {1..2}
#do
#    sudo lvcreate -L 50G -n k8s_50g_local_k8s_volume_${i} k8s_local_vol_group
#    sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i}
#    sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
#    sudo mount /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
#    sudo echo '/dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_50g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
#done

# Pre-create 50G volumes to be used by the K8s local-volume-provisioner
#for i in {1..2}
#do
#    sudo lvcreate -L 50G -n k8s_50g_local_k8s_volume_${i} k8s_local_vol_group
#    sudo mkfs.xfs /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i}
#    sudo mkdir -p ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
#    sudo mount /dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_${i} ${BASE_K8S_LOCAL_VOLUMES_DIR}/k8s_50g_local_k8s_volume_${i}
#    sudo echo '/dev/k8s_local_vol_group/k8s_50g_local_k8s_volume_'${i}' '${BASE_K8S_LOCAL_VOLUMES_DIR}'/k8s_50g_local_k8s_volume_'${i}' xfs defaults 0 0' | sudo tee -a /etc/fstab
#done

# Check logical partitions
sudo lvs
sudo df -hT
sudo lsblk
