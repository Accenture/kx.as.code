checkGlusterFsServiceInstalled() {
  rc=0
  sudo systemctl list-units --full -all | grep -F "glusterd.service" || rc=$? && log_info "Execution of checkGlusterFsServiceInstalled() returned with rc=$rc"
  if [[ $rc -eq 1 ]]; then
      log_info "This most likely means that GlusterFs was not installed. Will fall back to local storage for all storage-class assignments"
      export forceStorageClassToLocal="true"
    else
      log_info "Glusterfs is installed. Continuing with storage as defined in the solution's YAML configuration files"
      export forceStorageClassToLocal="false"
  fi
}