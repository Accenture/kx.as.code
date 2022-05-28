updateStorageClassIfNeeded() {
  log_info "Entered function updateStorageClassIfNeeded()"
  if [[ "${forceStorageClassToLocal}" == "true" ]]; then
    log_info "forceStorageClassToLocal was true. Modifying ${1} to use local storageClass"
    /usr/bin/sudo sed -i 's/gluster-heketi-sc/local-storage-sc/g' "${1}"
  else
    log_info "forceStorageClassToLocal was false. Leaving ${1} as is"
  fi
}