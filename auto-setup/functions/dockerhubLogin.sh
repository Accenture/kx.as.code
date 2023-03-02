dockerhubLogin() {

# Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local dockerHubUsername=$(getPassword "dockerhub_username" "base-user-${baseUser}")
  local dockerHubPassword=$(getPassword "dockerhub_password" "base-user-${baseUser}")

  if [[ -n ${dockerHubUsername} ]] && [[ -n ${dockerHubPassword} ]]; then

    # Log into the Docker registry, trying a maximum of ten times before giving up
    local i
    for i in {1..10}
    do
      echo ${dockerHubPassword} | docker login -u ${dockerHubUsername} --password-stdin || local rc=$?
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
    if [[ "$(cat /root/.docker/config.json | jq -r '.auths | has("https://index.docker.io/v1/")')" == "true" ]]; then
      log_debug "Dockerhub login successfully registered in Docker config file"
    else
      log_warn "Could not find the attempted Dockerhub login in the Docker config file. Login must have failed"
    fi

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
