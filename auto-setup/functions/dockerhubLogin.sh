dockerhubLogin() {

# Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  if [[ -f /var/tmp/.tmp.json ]]; then

    export dockerHubUsername=$(cat /var/tmp/.tmp.json | jq -r '.DOCKERHUB_USER')
    export dockerHubPassword=$(cat /var/tmp/.tmp.json | jq -r '.DOCKERHUB_PASSWORD')

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

  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
