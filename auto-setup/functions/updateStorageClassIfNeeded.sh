updateStorageClassIfNeeded() {
  if [[ "${forceStorageClassToLocal}" == "true" ]]; then
    sed -i 's/gluster-heketi-sc/local-storage-sc/g' "${1}"
  fi
}