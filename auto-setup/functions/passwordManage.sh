managedPassword() {

  passwordName=${1}
  passwordGroup=${2-}

  # Conditional statement in case this is being re-run for an already deployed solution
  if [[ -z $(getPassword "${passwordName}") ]]; then
    # Generate new secure password and push to GoPass
    generatedPassword="$(generatePassword)"
    pushPassword "${passwordName}" "${generatedPassword}" "${passwordGroup}"
  else
    # Pull existing password from GoPass as it already exists
    generatedPassword=$(getPassword "${passwordName}" "${passwordGroup}")
  fi
  echo "${generatedPassword}"
}
