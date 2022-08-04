managedPassword() {

  passwordName=${1}
  passwordGroup=${2-}

  # Conditional statement in case this is being re-run for an already deployed solution
  if [[ -n "${passwordGroup}" ]]; then
    generatedPassword=$(getPassword "${passwordName}" "${passwordGroup}")
  else
    generatedPassword=$(getPassword "${passwordName}")
  fi

  if [[ -z ${generatedPassword} ]]; then
    # Generate new secure password and push to GoPass
    generatedPassword="$(generatePassword)"
    if [[ -n "${passwordGroup}" ]]; then
      pushPassword "${passwordName}" "${generatedPassword}" "${passwordGroup}"
    else
      pushPassword "${passwordName}" "${generatedPassword}"
    fi
  fi

  echo "${generatedPassword}"

}
