managedPassword() {
  # Conditional statement in case this is being re-run for an already deployed solution
  if [[ -z $(getPassword "$1") ]]; then
    # Generate new secure password and push to GoPass
    generatedPassword=$(generatePassword)
    pushPassword "$1" "${generatedPassword}"
  else
    # Pull existing from GoPass password as it already exists
    generatedPassword=$(getPassword "$1")
  fi
  echo ${generatedPassword}
}
