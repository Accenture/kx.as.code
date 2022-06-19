checkAndUpdateBaseUsername() {

  if [[ "${vmUser}" != "${baseUser}" ]]; then

    # Create new username rather than modify the old one

    sourceGroups=$(id -Gn "kx.hero" | sed "s/ /,/g" | sed -r 's/\<'"kx.hero"'\>\b,?//g')
    sourceShell=$(awk -F : -v name="kx.hero" '(name == $1) { print $7 }' /etc/passwd)

    /usr/bin/sudo useradd --groups ${sourceGroups} --shell ${sourceShell} --create-home --home-dir /home/${baseUser} ${baseUser}

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
    /usr/bin/sudo cp -rfT ${installationWorkspace}/skel /home/${baseUser}
    /usr/bin/sudo rm -rf /home/${baseUser}/.cache/sessions

    # Get new user group ID
    newGid=$(id -g ${baseUser}) # In case script is re-run and the variable not set as a result
    /usr/bin/sudo chown -f -R ${newGid}:${newGid} /home/${baseUser} || true

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
    if /usr/bin/sudo test ! -f /home/${baseUser}/.config/autostart-scripts/showWelcome.sh; then
        /usr/bin/sudo mkdir -p /home/${baseUser}/.config/autostart-scripts
        /usr/bin/sudo cp -f ${installationWorkspace}/showWelcome.sh /home/${baseUser}/.config/autostart-scripts
        /usr/bin/sudo chmod -R 755 /home/${baseUser}/.config/autostart-scripts
        /usr/bin/sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}/.config/autostart-scripts
    fi

    # Ensure Desktop icons have execute permissions
    /usr/bin/sudo chmod 755 /home/${baseUser}/Desktop/*.desktop

    # Give user full sudo priviliges
    printf "${baseUser}        ALL=(ALL)       NOPASSWD: ALL\n" | /usr/bin/sudo tee -a /etc/sudoers

  fi
            
}