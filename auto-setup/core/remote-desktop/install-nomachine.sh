#!/bin/bash

# Do not install if public cloud or Raspberry Pi, as in these cases, NoMachine would have already been installed into the image.
if [[ -z $(which raspinfo) ]] && [[ "${installNoMachine}" == "true" ]]; then

  if ! apt list nomachine | grep -i "installed"; then
    majorNoMachineVersion=${nomachineVersion%.*}

    if [[ -n $( uname -a | grep "aarch64") ]]; then
      # Download URL for ARM64 CPU architecture
      nomachineUrl="https://download.nomachine.com/download/${majorNoMachineVersion}/Arm/nomachine_${nomachineVersion}_arm64.deb"
      nomachineChecksum="${nomachineArm64Checksum}"
    else
      # Download URL for X86_64 CPU architecture
      nomachineUrl="https://download.nomachine.com/download/${majorNoMachineVersion}/Linux/nomachine_${nomachineVersion}_amd64.deb"
      nomachineChecksum="${nomachineAmd64Checksum}"
    fi

    # Download NoMachine
    filename=$(basename "${nomachineUrl}")
    downloadFile "${nomachineUrl}" \
      "${nomachineChecksum}" \
      "${installationWorkspace}/${filename}" && log_info "Return code received after downloading ${filename} is $?"

    # Install NoMachine
    /usr/bin/sudo apt-get install -y ${installationWorkspace}/${filename}

    # Ensure NoMachine starts dedicated virtual display if private or public cloud
    /usr/bin/sudo sed -E -i 's/#PhysicalDisplays(.*)/PhysicalDisplays 1005/g' /usr/NX/etc/node.cfg
    /usr/bin/sudo sed -E -i 's/^DefaultDesktopCommand(.*)/DefaultDesktopCommand "env -u WAYLAND_DISPLAY \/usr\/bin\/dbus-launch --sh-syntax --exit-with-session \/usr\/bin\/startkde"/g' /usr/NX/etc/node.cfg
    /usr/bin/sudo sed -E -i 's/#DisplayBase(.*)/DisplayBase 1005/g' /usr/NX/etc/server.cfg
    /usr/bin/sudo sed -E -i 's/#CreateDisplay(.*)/CreateDisplay 1/g' /usr/NX/etc/server.cfg
    /usr/bin/sudo sed -E -i 's/#DisplayOwner(.*)/DisplayOwner '${vmUser}'/g' /usr/NX/etc/server.cfg
    /usr/bin/sudo sed -E -i 's/#DisplayGeometry(.*)/DisplayGeometry 1920x1200/g' /usr/NX/etc/server.cfg

    # Restart service after NX config change
    /usr/bin/sudo systemctl restart nxserver.service

  fi

fi
