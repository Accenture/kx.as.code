loginToCoreRegistry() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Get password
  export defaultRegistryUserPassword=$(managedApiKey "docker-registry-${baseUser}-password" "docker-registry")

  # Log into the Docker regitry, trying a maximum of ten times before giving up
  local i
  for i in {1..10}
  do
    echo ${defaultRegistryUserPassword} | docker login -u ${baseUser} https://docker-registry.${baseDomain} --password-stdin || local rc=$?
    if [[ ${rc} -eq 0 ]]; then
      log_debug "Successfully logged into local docker registry. Continuing"
      break
    else
      log_warn "Logging into the local docker registry failed. Trying again"
      sleep 10
    fi
  done

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
