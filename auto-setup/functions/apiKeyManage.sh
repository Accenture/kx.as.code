managedApiKey() {
  # Conditional statement in case this is being re-run for an already deployed solution
  if [[ -z $(getPassword "${1}") ]]; then
    # Generate new secure password and push to GoPass
    generatedApiKey="$(generateApiKey)"
    pushPassword "${1}" "${generatedApiKey}"
  else
    # Pull existing password from GoPass as it already exists
    generatedApiKey="$(getPassword \"${1}\")"
  fi
  echo "${generatedApiKey}"
}
