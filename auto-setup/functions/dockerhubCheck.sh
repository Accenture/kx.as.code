checkDockerHubRateLimit() {

  export dockerAuthApiUrl="https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull"

  local dockerHubUsername=$(getPassword "dockerhub_username" "base-technical-credentials")
  local dockerHubPassword=$(getPassword "dockerhub_password" "base-technical-credentials")
  local dockerHubEmail=$(getPassword "dockerhub_email" "base-technical-credentials")

  if [[ -n ${dockerHubUsername} ]] && [[ -n ${dockerHubPassword} ]]; then

    export dockerAuthApiUrl="https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull"
    if [[ -n ${dockerHubUsername} ]] && [[ -n ${dockerHubPassword} ]]; then
      dockerHubTokenJson=$(curl --user ''${dockerHubUsername}:${dockerHubPassword}'' "${dockerAuthApiUrl}")
    else
      dockerHubTokenJson=$(curl "${dockerAuthApiUrl}")
    fi
  else
    dockerHubTokenJson=$(curl "${dockerAuthApiUrl}")
  fi
  if [[ -n ${dockerHubTokenJson} ]]; then
    dockerHubToken=$(echo ${dockerHubTokenJson} | jq -r '.token')
  else
    log_debug "Could not get a valid respond from Dockerhub, so not able to calculate how many downloads are left"
    dockerHubAllowLimit=""
    dockerHubRemainingLimit=""
    exit 0
  fi
  curl -s --head -H "Authorization: Bearer ${dockerHubToken}" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest 2>&1 | sudo tee ${installationWorkspace}/rateLimitResponse.txt
  dockerHubRateLimitResponse=$(cat ${installationWorkspace}/rateLimitResponse.txt | grep -i RateLimit | cut -d' ' -f2 | cut -d';' -f1 || true)
  if [[ -n ${dockerHubRateLimitResponse} ]]; then
    dockerHubAllowLimit=$(echo ${dockerHubRateLimitResponse} | awk {'print $1'})
    dockerHubRemainingLimit=$(echo ${dockerHubRateLimitResponse} | awk {'print $2'})
  else
    log_warn "Received an empty response when retrieving the docker hub rate limit. Will continue anyway"
    dockerHubAllowLimit=""
    dockerHubRemainingLimit=""
  fi

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

}
