renewApiKey() {

  passwordName=${1}
  passwordGroup=${2:-}

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

}
