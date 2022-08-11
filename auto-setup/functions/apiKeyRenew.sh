renewApiKey() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  passwordName=${1}
  passwordGroup=${2-}

  # Conditional statement in case this is being re-run for an already deployed solution
  if [[ -n "${passwordGroup}" ]]; then
    if [[ -n $(getPassword "${passwordName}" "${passwordGroup}") ]]; then
      deletePassword "${passwordName}" "${passwordGroup}"
    fi
  else
    if [[ -n $(getPassword "${passwordName}") ]]; then
      deletePassword "${passwordName}"
    fi
  fi

  # Generate new secure api key and push to GoPass
  generatedApiKey="$(generateApiKey)"
  if [[ -n "${passwordGroup}" ]]; then
    pushPassword "${passwordName}" "${generatedApiKey}" "${passwordGroup}"
  else
    pushPassword "${passwordName}" "${generatedApiKey}"
  fi

  echo "${generatedApiKey}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
