deletePassword() {

  passwordName=${1}
  passwordGroup=${2-}

  # Conditional statement in case this is being re-run for an already deployed solution
  # Delete password from GoPass
  if [[ -n "${passwordGroup}" ]]; then 
    /usr/bin/sudo -H -i -u ${baseUser} bash -c "gopass delete --force \"${baseDomain}/${passwordGroup}/${passwordName}\""
  else
    /usr/bin/sudo -H -i -u ${baseUser} bash -c "gopass delete --force \"${baseDomain}/${passwordName}\""
  fi

}
