checkGlusterFsServiceInstalled() {
  rc=0
  sudo systemctl list-units --full -all | grep -F "glusterd.service" || rc=$? && echo "Execution of checkGlusterFsServiceInstalled() returned with rc=$rc"
  if [[ $rc -eq 1 ]]; then
      echo "This most likely means that GlusterFs was not installed. Will fall back to local storage for all storage-class assignments"
      export forceStorageClassToLocal="true"
    else
      echo "Glusterfs is installed. Continuing with storage as defined in the solution's YAML configuration files"
      export forceStorageClassToLocal="false"
  fi
}