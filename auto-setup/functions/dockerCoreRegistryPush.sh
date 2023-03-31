pushDockerImageToCoreRegistry() {
  
  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  imagePathToPush=${1}

  # Login
  loginToCoreRegistry

  # Push image to core registry
  rc=0
  for i in {1..5}
  do
    log_debug "docker push docker-registry.${baseDomain}/${imagePathToPush}"
    local dockerImagePushOutput=$(docker push docker-registry.${baseDomain}/${imagePathToPush}) || rc=$?  && log_info "Push to Docker returned with rc=${rc}"
    >&2 echo "${dockerImagePushOutput}"
    if [[ $rc -ne 0 ]]; then
      log_warn "Docker push exited with a non zero return code after try ${i}. Will try again a maximum of 5 times"
      rc=0 # Reset return code back to 0
    else
      log_info "Docker push exited with return code 0 after try ${i}. Looks good. Continuing."
      break
    fi
  done

  # Complete a final check to verify Docker now exists in Docker registry
  imageTagExists=$(dockerCoreRegistryCheckTagExists "${imagePathToPush}")
  if ${imageTagExists}; then
    local dockerImageSha=$(echo "${dockerImagePushOutput}" | tail -1 | cut -d' ' -f3)
    echo ${dockerImageSha}
  else
    return 1
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
