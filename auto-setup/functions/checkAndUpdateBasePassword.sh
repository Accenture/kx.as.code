checkAndUpdateBasePassword() {
  vmPassword=$(cat /usr/share/kx.as.code/.config/.user.cred)
  if [[ "${vmPassword}" != "${basePassword}" ]]; then
    /usr/bin/sudo usermod --password $(echo "${basePassword}" | openssl passwd -1 -stdin) "${baseUser}"
  fi
}