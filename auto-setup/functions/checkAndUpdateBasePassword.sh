checkAndUpdateBasePassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  vmPassword=$(cat /usr/share/kx.as.code/.config/.user.cred)
  if [[ "${vmPassword}" != "${basePassword}" ]]; then
    /usr/bin/sudo usermod --password $(echo "${basePassword}" | openssl passwd -1 -stdin) "${baseUser}"
  fi

   # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
   
}