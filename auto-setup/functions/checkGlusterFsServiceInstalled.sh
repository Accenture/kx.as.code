checkGlusterFsServiceInstalled() {
  rc=0
  sudo systemctl list-units --full -all | grep -Fq "glusterd.service" || rc=$? && echo "Execution of checkGlusterFsServiceInstalled() returned with rc=$rc"
  if [[ $rc -eq 1 ]]; then
      echo "This most likely means that GlusterFs was not installed. Will fall back to local storage for all storage-class assignments"
      export forceStorageClassToLocal="true"
    else
      export forceStorageClassToLocal="false"
  fi
}