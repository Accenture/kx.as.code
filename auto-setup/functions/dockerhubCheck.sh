checkDockerHubRateLimit() {

# Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  export dockerAuthApiUrl="https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull"
  if [[ -f /var/tmp/.tmp.json ]]; then
    export dockerHubUsername=$(cat /var/tmp/.tmp.json | jq -r '.DOCKERHUB_USER')
    export dockerHubPassword=$(cat /var/tmp/.tmp.json | jq -r '.DOCKERHUB_PASSWORD')
    export dockerHubEmail=$(cat /var/tmp/.tmp.json | jq -r '.DOCKERHUB_EMAIL')
    export dockerAuthApiUrl="https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull"
    if [[ -n ${dockerHubUsername} ]] && [[ -n ${dockerHubPassword} ]]; then
      dockerHubToken=$(curl --user ''${dockerHubUsername}:${dockerHubPassword}'' "${dockerAuthApiUrl}" | jq -r .token)
    else
      dockerHubToken=$(curl "${dockerAuthApiUrl}" | jq -r .token)
    fi
  else
    dockerHubToken=$(curl "${dockerAuthApiUrl}" | jq -r .token)
  fi
  curl --head -H "Authorization: Bearer ${dockerHubToken}" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest 2>&1 | sudo tee ${installationWorkspace}/rateLimitResponse.txt
  dockerHubRateLimitResponse=$(cat ${installationWorkspace}/rateLimitResponse.txt | grep -i RateLimit | cut -d' ' -f2 | cut -d';' -f1 || true)
  dockerHubAllowLimit=$(echo ${dockerHubRateLimitResponse} | awk {'print $1'})
  dockerHubRemainingLimit=$(echo ${dockerHubRateLimitResponse} | awk {'print $2'})
  if [[ -n ${dockerHubRemainingLimit} ]]; then
    dockerHubRateLimitTimePeriod=$(($(cat ${installationWorkspace}/rateLimitResponse.txt | grep "ratelimit-remaining" | cut -d'=' -f2 | tr -d " \t\n\r") / 3600))
    if [[ ${dockerHubRemainingLimit} -le 0 ]]; then
      log_error "Error\! You have 0 Docker Hub downloads remaining. You must wait until the next ${dockerHubRateLimitTimePeriod} hour period starts to try again"
      notify "Error\! You have 0 Docker Hub downloads remaining" "dialog-error"
    elif [[ ${dockerHubRemainingLimit} -le 25 ]]; then
      log_warn "Warning\! You have less than 25 Docker Hub downloads remaining"
      notify "Warning\! You have less than 25 Docker Hub downloads remaining" "dialog-warning"
    fi
    log_info "As an anonymous user you have a rate limit of ${dockerHubAllowLimit} with ${dockerHubRemainingLimit} downloads remaining in the current ${dockerHubRateLimitTimePeriod} hour window"
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
