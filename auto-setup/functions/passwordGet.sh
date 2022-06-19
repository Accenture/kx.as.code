getPassword() {
  # Retrieve the password from GoPass
  passwordName=$(echo ${1} | sed 's/ /-/g')
  /usr/bin/sudo -H -i -u ${baseUser} bash -c "gopass show --yes --password \"${baseDomain}/${passwordName}\""
  if [[ $? -eq 11 ]]; then
    >&2 log_warn "Password for \"${baseDomain}/${passwordName}\" not found. This may not be an issue if the calling script was just testing for it's existence, before deciding what to do next"
  fi
}
