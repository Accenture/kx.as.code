createUsers() {

  # Use input, else read users.json in workspace
  local firstname=${1:-}
  local surname=${2:-}
  local email=${3:-}
  local defaultUserKeyboardLanguage=${4:-}
  local userRole=${5:-}

  if [[ -z ${firstname} ]]; then
    local numUsersToCreate=$(jq -r '.config.additionalUsers[].firstname' ${installationWorkspace}/users.json | wc -l)
    local creationMode="users-json"
  else
    local numUsersToCreate=1
    local creationMode="singleUserCreation"
  fi
  export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
  export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")

  /usr/bin/sudo apt-get install -y unscd

  if [[ ${numUsersToCreate} -ne 0 ]]; then
    for i in $(seq 0 $((numUsersToCreate - 1))); do
      echo "i: $i"
      if [[ ${creationMode} != "singleUserCreation" ]]; then
        firstname=$(jq -r '.config.additionalUsers['$i'].firstname' ${installationWorkspace}/users.json)
        surname=$(jq -r '.config.additionalUsers['$i'].surname' ${installationWorkspace}/users.json)
        email=$(jq -r '.config.additionalUsers['$i'].email' ${installationWorkspace}/users.json)
        defaultUserKeyboardLanguage=$(jq -r '.config.additionalUsers['$i'].keyboard_language' ${installationWorkspace}/users.json)
        userRole=$(jq -r '.config.additionalUsers['$i'].role' ${installationWorkspace}/users.json)
      fi

      # Generate user id
      if [[ "${firstname}" == "Kx" ]]; then
        userid="kx.hero"
      else
        userid=$(generateUsername "${firstname}" "${surname}")
      fi

      # Check if user already exists in Guacamole database.
      # As this is the last action for user creation,
      # this would mean that user was already created successfully
      # and does not need to be created again
      mariadbAdminPassword=$(managedPassword "mariadb-admin-password" "remote-desktop")
      useridExistsInGuacamoleDatabase=$(echo "select name from guacamole_entity where name = '${userid}'" | /usr/bin/sudo mysql -sN --password="${mariadbAdminPassword}" guacamole_db)

      # Only create user if it does not already exist
      if [[ -z ${useridExistsInGuacamoleDatabase} ]]; then

        echo "${userid} ${firstname} ${surname} ${email}"

        # Get existing user password (${baseUser}[VM owner]] already has one) or generate new user password if not existing
        if test -z "$(getPassword "user-${userid}-password" "users")"; then
          export generatedPassword="$(generatePassword)"
        else
          export generatedPassword=$(getPassword "user-${userid}-password" "users")
        fi

        # Create user's desktop folder
        /usr/bin/sudo mkdir -p /home/${userid}/Desktop

        # Update user's home folder permissions
        /usr/bin/sudo chmod 700 /home/${userid}

        # Add admin tools folder to desktop if user has admin role
        if [[ "${userRole}" == "admin" ]]; then
          if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Admin Tools"; then
            /usr/bin/sudo ln -s "${adminShortcutsDirectory}" /home/${userid}/Desktop/
          fi
          createFileManagerShortcut "${adminShortcutsDirectory}" "${userid}" "folder-root"
        fi

        # Add Applications folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Applications"; then
          /usr/bin/sudo ln -s "${shortcutsDirectory}" /home/${userid}/Desktop/
        fi
        createFileManagerShortcut "${shortcutsDirectory}" "${userid}" "folder-favorites"

        # Add Tasks folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Tasks"; then
          /usr/bin/sudo ln -s "${taskShortcutsDirectory}" /home/${userid}/Desktop/
        fi
        createFileManagerShortcut "${taskShortcutsDirectory}" "${userid}" "folder-script"

        # Add Vendor Docs folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Vendor Docs"; then
          /usr/bin/sudo ln -s "${vendorDocsDirectory}" /home/${userid}/Desktop/
        fi
        createFileManagerShortcut "${vendorDocsDirectory}" "${userid}" "folder-text"

        # Add API Docs folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"API Docs"; then
          /usr/bin/sudo ln -s "${apiDocsDirectory}" /home/${userid}/Desktop/
        fi
        createFileManagerShortcut "${apiDocsDirectory}" "${userid}" "folder-text"

        # Add Logs folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Logs"; then
          /usr/bin/sudo ln -s "${logsDirectory}" /home/${userid}/Desktop/
        fi
        createFileManagerShortcut "${logsDirectory}" "${userid}" "folder-text"

        # Copy all file to user
        /usr/bin/sudo cp -rfT "${skelDirectory}" /home/${userid}
        /usr/bin/sudo rm -rf /home/${userid}/.cache/sessions

        if ! /usr/bin/sudo ldapsearch -x -D "cn=admin,${ldapDn}" -w ${ldapAdminPassword} -H ldapi:/// -b "ou=Users,ou=People,${ldapDn}" uid=${userid} | grep numEntries; then
          log_debug "User uid=${userid} does not exist in LDAP. Creating..."

          if id -g ${userid}; then
            # Use existing GID
            newGid=$(id -g ${userid})
          else
            # Determine new UID/GID for new user
            lastLdapGid=$(/usr/bin/sudo ldapsearch -x -b "ou=People,${ldapDn}" -D "cn=admin,${ldapDn}" -w ${ldapAdminPassword} -H ldapi:/// | grep gidNumber | sed 's/gidNumber: //' | sort | uniq | tail -1)
            log_debug "Last GID: $lastLdapGid"
            for i in {1..5}; do
              # Check UID/GID not already in use outside of LDAP, eg in /etc/passwd
              testId=$(grep "$(((${lastLdapGid} + $i)))" /etc/passwd || :)
              if [[ -n ${testId} ]]; then
                log_debug "GID $(((${lastLdapGid} + $i))) exists, incrementing +1 again"
              else
                newGid=$(((${lastLdapGid} + $i)))
                log_debug "GID ${newGid} does not already exist, using it\n"
                break
              fi
            done
          fi
          echo "New GID: $newGid"

          # Add User Group to OpenLDAP for Linux login
          if ! /usr/bin/sudo ldapsearch -x -b "ou=Groups,ou=People,${ldapDn}" -D "cn=admin,${ldapDn}" -w ${ldapAdminPassword} -H ldapi:/// cn=${userid} | grep numEntries; then
            echo '''
                      dn: cn='${userid}',ou=Groups,ou=People,'${ldapDn}'
                      objectClass: posixGroup
                      cn: '${userid}'
                      gidNumber: '${newGid}'
                      ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/users_group_${userid}.ldif
            /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/users_group_${userid}.ldif
          fi

          # Add User to OpenLDAP
          if ! /usr/bin/sudo ldapsearch -x -D "cn=admin,${ldapDn}" -w ${ldapAdminPassword} -H ldapi:/// -b "ou=Users,ou=People,${ldapDn}" uid=${userid} | grep numEntries; then
            echo '''
                      dn: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
                      objectClass: top
                      objectClass: posixAccount
                      objectClass: shadowAccount
                      objectClass: inetOrgPerson
                      objectClass: organizationalPerson
                      objectClass: person
                      cn: '${userid}'
                      sn: '${userid}'
                      uid: '${userid}'
                      uidNumber: '${newGid}'
                      gidNumber: '${newGid}'
                      homeDirectory: /home/'${userid}'
                      userPassword: '${generatedPassword}'
                      mail: '${email}'
                      loginShell: /bin/zsh
                      ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/new_user_${userid}.ldif
            /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/new_user_${userid}.ldif
          fi

          # Restart NSLCD and NSCD to make new users available for logging in
          /usr/bin/sudo systemctl restart nslcd.service
          /usr/bin/sudo systemctl restart unscd.service

          # Test for user availability
          for i in {1..15}; do
            echo "i: $i"
            if /usr/bin/sudo -H -i -u ${userid} bash -c 'id'; then
              break
            else
              sleep 10
            fi
          done

          # Check new user user via getent and ldapsearch
          if [[ -z ${newGid} ]]; then
            /usr/bin/sudo getent passwd | grep ${userid} # Check ldap user is active, ie. shows up with getent
            /usr/bin/sudo getent group | grep ${userid}  # Check ldap group is active, ie. shows up with getent
            newGid=$(id -g ${userid})
          else
            /usr/bin/sudo getent passwd | grep ${newGid} # Check ldap user is active, ie. shows up with getent
            /usr/bin/sudo getent group | grep ${newGid}  # Check ldap group is active, ie. shows up with getent
          fi
          /usr/bin/sudo ldapsearch -x -b "ou=People,${ldapDn}" -D "cn=admin,${ldapDn}" -w ${ldapAdminPassword} -H ldapi:///

          # Create "groupOfNames" group for Keycloak if it does not already exist
          if ! ldapsearch -D cn=admin,${ldapDn} -w ${ldapAdminPassword} -b "ou=Groups,ou=People,${ldapDn}" cn=kcadmins | grep numEntries; then
            # Create kcadmins group with new user
            echo '''
                        dn: cn=kcadmins,ou=Groups,ou=People,'${ldapDn}'
                        objectClass: groupOfNames
                        cn: kcadmins
                        member: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
                        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/create-groupOfNames-group.ldif
            /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/create-groupOfNames-group.ldif
          else
            if ! ldapsearch -D cn=admin,${ldapDn} -w ${ldapAdminPassword} -H ldapi:/// "(uid=${userid})" -b "ou=People,${ldapDn}" memberOf | grep numEntries; then
              # Add user to existing kcadmins group
              echo '''
                        dn: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
                        changetype: modify
                        add: memberOf
                        memberOf: cn=kcadmins,ou=Groups,ou=People,'${ldapDn}'
                        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/add_user_${userid}_to_kcadmins.ldif
              /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/add_user_${userid}_to_kcadmins.ldif
            fi
          fi

          # Check user was added successfully
          /usr/bin/sudo ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "${ldapDn}" memberOf 2>/dev/null | grep memberOf

          # Give user full sudo priviliges
          printf "${userid}        ALL=(ALL)       NOPASSWD: ALL\n" | /usr/bin/sudo tee -a /etc/sudoers
        else
          log_debug "User uid=${userid} already exists in LDAP. Skipping creation"
        fi

        # Set default keyboard language as per users.json
        keyboardLanguages=""
        availableLanguages="us"
        for language in ${availableLanguages}; do
          if [[ -z ${keyboardLanguages} ]]; then
            keyboardLanguages="${language}"
          else
            if [[ ${language} == "${defaultUserKeyboardLanguage}" ]]; then
              keyboardLanguages="${language},${keyboardLanguages}"
            else
              keyboardLanguages="${keyboardLanguages},${language}"
            fi
          fi
        done

        if /usr/bin/sudo test ! -f /home/${userid}/.config/autostart/keyboard-language.desktop; then
          echo """[Desktop Entry]
                Type=Application
                Name=SetKeyboardLanguage
                Exec=setxkbmap ${keyboardLanguages}
                """ | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /home/${userid}/.config/autostart/keyboard-language.desktop
        fi

        # Assign random avatar to user
        ls /usr/share/avatars/avatar_*.png | sort -R | tail -1 | while read file; do
          if [[ -z $(diff "${skelDirectory}"/.face.icon /home/${userid}/.face.icon) ]]; then
            /usr/bin/sudo cp -f $file /home/${userid}/.face.icon
            echo "Set face avatar to ${file}"
          fi
        done

        # Loop change ownership to wait for OpenLDAP user to be available for setting ownership
        newUid=$(id -u ${userid}) # In case script is re-run and the variable not set as a result
        newGid=$(id -g ${userid}) # In case script is re-run and the variable not set as a result
        for i in {1..10}; do
          echo "i: $i"
          /usr/bin/sudo chown -f -R ${newUid}:${newGid} /home/${userid} || true
          if [[ $(stat -c '%u' /home/${userid} || true) -eq ${newUid} ]]; then
            break
          else
            sleep 10
          fi
        done

        # Add KX.AS.CODE Root CA cert to Chrome CA Store
        if /usr/bin/sudo test ! -f /home/${userid}/.pki/nssdb; then
          /usr/bin/sudo rm -rf /home/${userid}/.pki
          mkdir -p /home/${userid}/.pki/nssdb/
          chown -R ${newUid}:${newGid} /home/${userid}/.pki
          /usr/bin/sudo -H -i -u ${userid} bash -c "certutil -N --empty-password -d sql:/home/${userid}/.pki/nssdb"
          /usr/bin/sudo -H -i -u ${userid} bash -c "/usr/local/bin/trustKXRootCAs.sh"
          /usr/bin/sudo -H -i -u ${userid} bash -c "certutil -L -d sql:/home/${userid}/.pki/nssdb"
        fi

        # Create SSH key kx.hero user
        if /usr/bin/sudo test ! -f /home/${userid}/.ssh/id_rsa; then
          /usr/bin/sudo chmod 700 /home/${userid}/.ssh
          /usr/bin/sudo -H -i -u ${userid} bash -c "yes | ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${userid}/.ssh/id_rsa -N ''"
          /usr/bin/sudo -H -i -u ${userid} bash -c "cat /home/${userid}/.ssh/id_rsa.pub | tee -a /home/${userid}/.ssh/authorized_keys"
        fi

        # Add desktop customization script to new users autostart-scripts folder
        if /usr/bin/sudo test ! -f /home/${userid}/.config/autostart-scripts/initializeDesktop.sh; then
          /usr/bin/sudo mkdir -p /home/${userid}/.config/autostart-scripts
          /usr/bin/sudo cp -f ${skelDirectory}/.config/autostart-scripts/initializeDesktop.sh /home/${userid}/.config/autostart-scripts
          /usr/bin/sudo chmod -R 755 /home/${userid}/.config/autostart-scripts
          /usr/bin/sudo chown -R ${userid}:${userid} /home/${userid}/.config/autostart-scripts
        fi

        if /usr/bin/sudo test ! -f /home/${userid}/.kube/config; then
          # Create Kubeconfig file
          /usr/bin/sudo mkdir -p /home/${userid}/.kube
          /usr/bin/sudo cat /etc/kubernetes/admin.conf | sed '/users:/,$d' | sed 's/kubernetes-admin/oidc/g' | /usr/bin/sudo tee /home/${userid}/.kube/config
          /usr/bin/sudo chown -R ${userid}:${userid} /home/${userid}/.kube
          /usr/bin/sudo chmod 600 /home/${userid}/.kube/config
        fi

        if [[ "${kubeOrchestrator}" == "k3s" ]]; then
          export kubeConfigFile=/etc/rancher/k3s/k3s.yaml
        else
          export kubeConfigFile=/etc/kubernetes/admin.conf
        fi

        /usr/bin/sudo -H -i -u ${userid} sh -c "mkdir -p /home/${userid}/.kube"
        /usr/bin/sudo cp -f ${kubeConfigFile} /home/${userid}/.kube/config

        # Ensure user has correct access permissions to .kube/config file
        /usr/bin/sudo chmod 600 /home/${userid}/.kube/config
        /usr/bin/sudo chown ${userid}:${userid} /home/${userid}/.kube/config

        if [[ -z $(cat /home/${userid}/.bashrc | grep KUBECONFIG) ]]; then
          echo "export KUBECONFIG=/home/${userid}/.kube/config" | /usr/bin/sudo tee -a /home/${userid}/.bashrc /home/${userid}/.zshrc
        fi

        if [[ -f ${installationWorkspace}/client-oidc-setup.sh ]]; then

          # Enable OIDC for accessing Kubernetes cluster if available.
          if checkApplicationInstalled "keycloak" "core"; then ###########

            # Source Keycloak Environment
            sourceKeycloakEnvironment

            # Call function to login to Keycloak
            keycloakLogin

            # Enable Keycloak OIDC for new user
            /usr/bin/sudo -H -i -u ${userid} bash -c "export KUBECONFIG=/home/${userid}/.kube/config && ${installationWorkspace}/client-oidc-setup.sh"
            /usr/bin/sudo -H -i -u ${userid} bash -c "export KUBECONFIG=/home/${userid}/.kube/config && kubectl config set-context --current --user=oidc"

            # Get Keycloak User Id
            export kcUserId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
              ${kcAdmCli} get users -r ${kcRealm} -q username=${userid} | jq -r '.[].id')

            # Create K8s cluster role binding for OIDC user if it does not exist
            /usr/bin/sudo kubectl get clusterrolebinding oidc-cluster-admin-${userid} ||
              /usr/bin/sudo kubectl create clusterrolebinding oidc-cluster-admin-${userid} --clusterrole=cluster-admin --user='https://keycloak.'${baseDomain}'/auth/realms/'${kcRealm}'#'${kcUserId}''

          fi ##########

        fi

        # Ensure user has correct access permissions to desktop files
        /usr/bin/sudo chmod 755 /home/${userid}/Desktop/*.desktop
        /usr/bin/sudo chown ${userid}:${userid} /home/${userid}/Desktop/*.desktop

        # Initialize gnupg for new user to use with GoPass
        gnupgInitializeUser "${userid}" "${generatedPassword}"

        # Add user password to user's gopass repository if it does not already exist
        if test -z "$(getPassword "user-${userid}-password" "users")"; then
          pushPassword "user-${userid}-password" "${generatedPassword}" "users"
        fi

        # Add user to Docker Registry
        dockerRegistryAddUser "${userid}" "sso-user"

        # Create Guacamole user
        guacamoleCreateDbUser "${userid}"

        # Assign Guacamole user permissions for self administration
        guacamoleAssignUserPermissions "${userid}"

        # Assign Guacamole XRDP connection
        guacamoleAssignUserXrpConnection "${userid}"

        # Assign Guacamole system administration rights
        if [[ "${userRole}" == "admin" ]]; then
          guacamoleAssignAdminPermissions "${userid}"
        fi

        # Lastly, add users to local /etc/group and /etc/passwd files
        # Without this additional step, Guacamole users cannot log in to desktop
        # Future TODO: Make desktop access work with LDAP only
        if [[ -z $(grep "${userid}" /etc/group) ]]; then
          echo "${userid}:x:${newGid}:" | /usr/bin/sudo tee -a /etc/group
        fi
        if [[ -z $(grep "${userid}" /etc/passwd) ]]; then
          echo "${userid}:x:${newUid}:${newGid}::/home/${userid}:/bin/zsh" | /usr/bin/sudo tee -a /etc/passwd
        fi
        # Set user LDAP password also at system level, so XRDP authorization can succeed
        /usr/bin/sudo usermod --password $(echo "${generatedPassword}" | openssl passwd -1 -stdin) "${userid}"

      else
        log_debug "User with id \"${userid}\" already exists. Skipping creation"
      fi

    done
  fi

}
