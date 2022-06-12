disableLinuxDesktop() {

  # Read disable linux desktop property from profile configuration
  disableLinuxDesktop=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.disableLinuxDesktop')

  if [[ ${disableLinuxDesktop} == "true" ]]; then

    # Backup original Grub file that starts KDE Plasma
    /usr/bin/sudo cp /etc/default/grub /etc/default/grub.gui

    # Replace with value to
    sed -i '/GRUB_CMDLINE_LINUX/s/".*"/"text"/' /etc/default/grub
    sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' /etc/default/grub
    /usr/bin/sudo  update-grub
    /usr/bin/sudo  systemctl set-default multi-user.target

    # Create script for re-enabling desktop
    echo '''#!/bin/bash
    sudo cp /etc/default/grub /etc/default/grub.console
    sudo cp /etc/default/grub.gui /etc/default/grub
    sudo systemctl set-default graphical.target
    ''' | /usr/bin/sudo tee ${installationWorkspace}/reEnableKdeDesktopOnBoot.sh

    /usr/bin/sudo chmod 755 tee ${installationWorkspace}/reEnableKdeDesktopOnBoot.sh

  fi
}
