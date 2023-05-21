checkAndUpdateBasePassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Update user with password in profile-config.json
  /usr/bin/sudo usermod --password $(echo "${basePassword}" | openssl passwd -1 -stdin) "${baseUser}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
   
}