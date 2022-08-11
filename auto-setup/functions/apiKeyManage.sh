managedApiKey() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart
  
  passwordName=${1}
  passwordGroup=${2-}

  # Conditional statement in case this is being re-run for an already deployed solution
  if [[ -n "${passwordGroup}" ]]; then
    generatedApiKey=$(getPassword "${passwordName}" "${passwordGroup}")
  else
    generatedApiKey=$(getPassword "${passwordName}")
  fi

  if [[ -z ${generatedApiKey} ]]; then
    # Generate new secure password and push to GoPass
    generatedApiKey="$(generateApiKey)"
    if [[ -n "${passwordGroup}" ]]; then
      pushPassword "${passwordName}" "${generatedApiKey}" "${passwordGroup}"
    else
      pushPassword "${passwordName}" "${generatedApiKey}"
    fi
  fi

  echo "${generatedApiKey}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
