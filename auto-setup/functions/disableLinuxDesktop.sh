disableLinuxDesktop() {

  # Read disable linux desktop property from profile configuration
  disableLinuxDesktop=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.disableLinuxDesktop')

  if [[ ${disableLinuxDesktop} == "true" ]]; then

    # Backup original Grub file that starts KDE Plasma
    /usr/bin/sudo cp /etc/default/grub /etc/default/grub.gui

    # Replace with value to
    /usr/bin/sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/s/\".*\"/\"text\"/' /etc/default/grub
    /usr/bin/sudo sed -i 's/GRUB_CMDLINE_LINUX=/#GRUB_CMDLINE_LINUX=/g' /etc/default/grub
    /usr/bin/sudo sed -i 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' /etc/default/grub
    /usr/bin/sudo  update-grub
    /usr/bin/sudo  systemctl set-default multi-user.target

  fi
}
