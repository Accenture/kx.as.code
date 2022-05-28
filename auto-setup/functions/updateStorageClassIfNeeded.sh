updateStorageClassIfNeeded() {
  if [[ "${forceStorageClassToLocal}" == "true" ]]; then
    sudo sed -i 's/gluster-heketi-sc/local-storage-sc/g' "${1}"
  fi
}