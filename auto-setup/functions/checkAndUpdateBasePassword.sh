checkAndUpdateBasePassword() {

  export generatedPassword="$(generatePassword)"
  /usr/bin/sudo usermod --password $(echo "${generatedPassword}" | openssl passwd -1 -stdin) "${baseUser}"
  echo "${generatedPassword}" | /usr/bin/sudo tee ${sharedKxHome}/.config/.user.cred
  /usr/bin/sudo chown 400 ${sharedKxHome}/.config/.user.cred

}
