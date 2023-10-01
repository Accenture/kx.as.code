checkAndUpdateBaseUsername() {

  # Check if owner details defined in users.json
  firstname=$(jq -r '.config.owner.firstname' ${installationWorkspace}/users.json)
  surname=$(jq -r '.config.owner.surname' ${installationWorkspace}/users.json)
  email=$(jq -r '.config.owner.email' ${installationWorkspace}/users.json)
  defaultUserKeyboardLanguage=$(jq -r '.config.owner.keyboard_language' ${installationWorkspace}/users.json)
  userRole=$(jq -r '.config.owner.role' ${installationWorkspace}/users.json)

  if [[ -n ${firstname} ]] && [[ "${firstname}" != "null" ]]; then
   export baseUser=$(getOwnerId)
  else
   export baseUser="kx.hero"
  fi

  if ! id ${baseUser}; then

    if [[ "${vmUser}" != "${baseUser}" ]]; then      

      # Create new username rather than modify the old one
      sourceGroups=$(id -Gn "${vmUser}" | sed "s/ /,/g" | sed -r 's/\<'"${vmUser}"'\>\b,?//g')
      sourceShell=$(awk -F : -v name="${vmUser}" '(name == $1) { print $7 }' /etc/passwd)

      # Create user
      /usr/bin/sudo useradd --groups ${sourceGroups} --shell ${sourceShell} --create-home --home-dir /home/${baseUser} ${baseUser}

      # Give base user id 1000 to avoid later permission issues with process running inside and outside of Docker/Kubernetes
      baseUserUid="$(id -u ${baseUser})"
      baseUserGid="$(id -g ${baseUser})"
      thousandIdUserName="$(id -nu 1000)"

      # Swap uids around in /etc/passwd
      /usr/bin/sudo sed -i 's/'${thousandIdUserName}':x:1000:1000/'${thousandIdUserName}':x:'${baseUserUid}':'${baseUserGid}'/g' /etc/passwd
      /usr/bin/sudo sed -i 's/'${baseUser}':x:'${baseUserUid}':'${baseUserGid}'/'${baseUser}':x:1000:1000/g' /etc/passwd

      # Swap gids around in /etc/group
      /usr/bin/sudo sed -i 's/'${thousandIdUserName}':x:1000:/'${thousandIdUserName}':x:'${baseUserGid}':/g' /etc/group
      /usr/bin/sudo sed -i 's/'${baseUser}':x:'${baseUserGid}':/'${baseUser}':x:1000:/g' /etc/group

      # Correct permissions after the id changes
      /usr/bin/sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}
      /usr/bin/sudo chown -R ${thousandIdUserName}:${thousandIdUserName} /home/${thousandIdUserName}

      # Create user's desktop folder
      /usr/bin/sudo mkdir -p /home/${baseUser}/Desktop

      # Add admin tools folder to desktop if user has admin role
      if /usr/bin/sudo test ! -e /home/${baseUser}/Desktop/"Admin Tools"; then
          /usr/bin/sudo ln -s "${adminShortcutsDirectory}" /home/${baseUser}/Desktop/
      fi

      # Add DevOps tools folder to desktop
      if /usr/bin/sudo test ! -e /home/${baseUser}/Desktop/"Applications"; then
          /usr/bin/sudo ln -s "${shortcutsDirectory}" /home/${baseUser}/Desktop/
      fi

      # Add Vendor Docs folder to desktop
      if /usr/bin/sudo test ! -e /home/${baseUser}/Desktop/"Vendor Docs"; then
          /usr/bin/sudo ln -s "${vendorDocsDirectory}" /home/${baseUser}/Desktop/
      fi

      # Add API Docs folder to desktop
      if /usr/bin/sudo test ! -e /home/${baseUser}/Desktop/"API Docs"; then
          /usr/bin/sudo ln -s "${apiDocsDirectory}" /home/${baseUser}/Desktop/
      fi

      # Copy all file to user
      /usr/bin/sudo cp -rfT "${skelDirectory}" /home/${baseUser}
      /usr/bin/sudo rm -rf /home/${baseUser}/.cache/sessions

      # Get new user and group IDs
      newUid=$(id -u ${baseUser}) # In case script is re-run and the variable not set as a result
      newGid=$(id -g ${baseUser}) # In case script is re-run and the variable not set as a result
      /usr/bin/sudo chown -f -R ${newUid}:${newGid} /home/${baseUser} || true

      # Create SSH directory
      if [ ! -d /home/${baseUser}/.ssh ]; then

          # Create the kx.hero user ssh directory.
          /usr/bin/sudo mkdir -pm 700 /home/${baseUser}/.ssh

          # Ensure the permissions are set correct
          /usr/bin/sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}/.ssh
      fi

      # Create SSH key kx.hero user
      if /usr/bin/sudo test ! -f /home/${baseUser}/.ssh/id_rsa; then
          /usr/bin/sudo chmod 700 /home/${baseUser}/.ssh
          /usr/bin/sudo -H -i -u ${baseUser} bash -c "yes | ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${baseUser}/.ssh/id_rsa -N ''"
      fi

      # Add desktop customization script to new users autostart-scripts folder
      if /usr/bin/sudo test ! -f /home/${baseUser}/.config/autostart-scripts/initializeDesktop.sh; then
          /usr/bin/sudo mkdir -p /home/${baseUser}/.config/autostart-scripts
          /usr/bin/sudo cp -f ${skelDirectory}/.config/autostart-scripts/initializeDesktop.sh /home/${baseUser}/.config/autostart-scripts
          /usr/bin/sudo chmod -R 755 /home/${baseUser}/.config/autostart-scripts
          /usr/bin/sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}/.config/autostart-scripts
      fi

      # Ensure Desktop icons have execute permissions
      /usr/bin/sudo chmod 755 /home/${baseUser}/Desktop/*.desktop

      # Give user full sudo priviliges
      printf "${baseUser}        ALL=(ALL)       NOPASSWD: ALL\n" | /usr/bin/sudo tee -a /etc/sudoers

      # Hide old base user kx.hero
      /usr/bin/sudo sed -i '/^HideUsers=vagrant/ s/$/,'${vmUser}'/' /etc/sddm.conf

      # Update permission on Git repository
      /usr/bin/sudo chown -R ${baseUser}:${baseUser} ${sharedGitHome}

    fi

  fi

}