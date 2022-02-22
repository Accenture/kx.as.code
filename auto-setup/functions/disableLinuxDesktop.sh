disableLinuxDesktop() {
  disableLinuxDesktop=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.disableLinuxDesktop')
  if [[ ${disableLinuxDesktop} == "true" ]]; then
    systemctl set-default multi-user
    systemctl isolate multi-user.target
  fi
}
