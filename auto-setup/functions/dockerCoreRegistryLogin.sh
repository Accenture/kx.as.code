loginToCoreRegistry() {

  local dockerUser=${1:-}
  local userType=${2:-}

  # Check Docker Registry has running pods, not just an empty namespace
  local dockerRegistryPods=$(kubectl get pods -n docker-registry -o json | jq -r '.items[].status | select(.phase=="Running") | .phase | select(.!=null)')
  if [[ -n  ${dockerRegistryPods} ]]; then

    # Get password
    #export dockerPassword=$(managedApiKey "docker-registry-${baseUser}-password" "docker-registry")

    # Get password
    if [[ "${userType}" == "sso-user" ]] && [[ -n ${dockerUser} ]]; then
      export dockerPassword=$(managedPassword "user-${dockerUser}-password" "users")
    elif [[ -n ${dockerUser} ]]; then
      export dockerPassword=$(managedApiKey "docker-registry-${dockerUser}-password" "docker-registry")
    else 
      export dockerPassword=$(managedApiKey "docker-registry-${namespace}-password" "docker-registry")
      export dockerUser=${namespace}
    fi

    # Log into the Docker registry, trying a maximum of ten times before giving up
    local i
    for i in {1..100}
    do
      log_debug "COMMAND: echo ${dockerPassword} | >&2 docker login -u ${dockerUser} https://docker-registry.${baseDomain} --password-stdin"
      echo ${dockerPassword} | >&2 docker login -u ${dockerUser} https://docker-registry.${baseDomain} --password-stdin || local rc=$?
      if [[ ${rc} -eq 0 ]]; then
        log_debug "Successfully logged into local docker registry. Continuing"
        break
      else
        log_warn "Logging into the local docker registry failed. Trying again"
        rc=0 # Reset return code back to 0
        sleep 10
      fi
    done

    # Confirm login credentials are accessible
    if [[ "$(cat /root/.docker/config.json | jq -r '.auths | has("docker-registry.'${baseDomain}'")')" == "true" ]]; then
      log_debug "Core docker registry login successfully registered in Docker config file"
    else
      log_error "Could not find the attempted core docker registry login in the Docker config file. Login must have failed"
      exit 1
    fi

  else
    log_info "Not logging in to docker-registry, as docker-registry not yet running"
  fi

}
