createExternalAccessDirectory() {

  if [[ -d /vagrant ]]; then
    if [[ -z $(df -h | grep vagrant) ]]; then
      /usr/bin/sudo mount -a
    fi
    /usr/bin/sudo mkdir -p /vagrant/kx-external-access
    export externalAccessDirectory="/vagrant/kx-external-access"
  else
    /usr/bin/sudo mkdir /kx-external-access
    export externalAccessDirectory="/kx-external-access"
  fi

  # Ensure directory is cleaned on first start of KX.AS.CODE
  if [[ "$(cat ${profileConfigJsonPath} | jq -r '.state.networking_configuration_status')" != "done" ]]; then
    /usr/bin/sudo rm -f ${externalAccessDirectory}/*
  fi

  log_debug "Set externalAccessDirectory to ${externalAccessDirectory}"

}
