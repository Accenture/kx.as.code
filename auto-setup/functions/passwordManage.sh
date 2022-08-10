managedPassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

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

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
