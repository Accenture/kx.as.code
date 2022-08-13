createExternalAccessDirectory() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  if [[ -d /vagrant ]]; then
    if [[ -z $(df -h | grep vagrant) ]]; then
      /usr/bin/sudo mount -a
    fi
    /usr/bin/sudo mkdir -p /vagrant/kx-external-access
    export externalAccessDirectory=/vagrant/kx-external-access
  elif [[ ! -d /kx-external-access ]]; then
    /usr/bin/sudo mkdir /kx-external-access
    export externalAccessDirectory=/kx-external-access
  fi

  # Ensure directory is cleaned on first start of KX.AS.CODE
  if [[ ! -f /usr/share/kx.as.code/.config/network_status  ]]; then
    /usr/bin/sudo rm -f ${externalAccessDirectory}/*
  fi

  log_debug "Set externalAccessDirectory to ${externalAccessDirectory}"

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}

