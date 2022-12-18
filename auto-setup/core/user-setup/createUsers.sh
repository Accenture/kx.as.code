#!/bin/bash
set -euox pipefail

export numUsersToCreate=$(jq -r '.config.additionalUsers[].firstname' ${installationWorkspace}/users.json | wc -l)
export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")

newGid=""

/usr/bin/sudo apt-get install -y unscd

if [[ ${numUsersToCreate} -ne 0 ]]; then
    for i in $(seq 0 $((numUsersToCreate - 1))); do
        echo "i: $i"
        firstname=$(jq -r '.config.additionalUsers['$i'].firstname' ${installationWorkspace}/users.json)
        surname=$(jq -r '.config.additionalUsers['$i'].surname' ${installationWorkspace}/users.json)
        email=$(jq -r '.config.additionalUsers['$i'].email' ${installationWorkspace}/users.json)
        defaultUserKeyboardLanguage=$(jq -r '.config.additionalUsers['$i'].keyboard_language' ${installationWorkspace}/users.json)
        userRole=$(jq -r '.config.additionalUsers['$i'].role' ${installationWorkspace}/users.json)

        firstnameSubstringLength=$((8 - ${#surname}))

        if [[ ${firstnameSubstringLength} -le 0 ]]; then
            firstnameSubstringLength=1
        fi
        echo $firstnameSubstringLength
        userid="$(echo ${surname,,} | cut -c1-7)$(echo ${firstname,,} | cut -c1-${firstnameSubstringLength})"

        echo "${userid} ${firstname} ${surname} ${email}"

        # Generate User Password
        export generatedPassword=$(managedPassword "user-${userid}-password" "users")

        # Create user's desktop folder
        /usr/bin/sudo mkdir -p /home/${userid}/Desktop

        # Add admin tools folder to desktop if user has admin role
        if [[ "${userRole}" == "admin" ]]; then
            if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Admin Tools"; then
                /usr/bin/sudo ln -s "${adminShortcutsDirectory}" /home/${userid}/Desktop/
            fi
        fi

        # Add DevOps tools folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Applications"; then
            /usr/bin/sudo ln -s "${shortcutsDirectory}" /home/${userid}/Desktop/
        fi

        # Add Vendor Docs folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"Vendor Docs"; then
            /usr/bin/sudo ln -s "${vendorDocsDirectory}" /home/${userid}/Desktop/
        fi

        # Add API Docs folder to desktop
        if /usr/bin/sudo test ! -e /home/${userid}/Desktop/"API Docs"; then
            /usr/bin/sudo ln -s "${apiDocsDirectory}" /home/${userid}/Desktop/
        fi

        # Copy all file to user
        /usr/bin/sudo cp -rfT "${skelDirectory}" /home/${userid}
        /usr/bin/sudo rm -rf /home/${userid}/.cache/sessions

        if ! id -u ${userid} > /dev/null 2>&1; then

            if [ ! -f /home/${userid}/.ssh/id_rsa ]; then
                # Create the kx.hero user ssh directory.
                /usr/bin/sudo mkdir -pm 700 /home/${userid}/.ssh

                # Ensure the permissions are set correct
                for i in {1..20}; do
                    echo "i: $i"
                    /usr/bin/sudo chown -R ${userid}:${userid} /home/${userid}/.ssh || true
                    if [[ $(stat -c '%u' /home/${userid}/.ssh) -eq ${newGid} ]]; then
                        break
                    else
                        sleep 15
                    fi
                done

            fi

            # Determine UID/GID for new user
            lastLdapGid=$(/usr/bin/sudo ldapsearch -x -b "ou=People,${ldapDn}" | grep gidNumber | sed 's/gidNumber: //' | sort | uniq | tail -1)
            echo "Last GID: $lastLdapGid"
            newGid=$((lastLdapGid + 1))
            echo "New GID: $newGid"

            # Add User Group to OpenLDAP for Linux login
            if ! /usr/bin/sudo ldapsearch -x -b "cn=${userid},ou=Groups,ou=People,${ldapDn}"; then
            echo '''
      dn: cn='${userid}',ou=Groups,ou=People,'${ldapDn}'
      objectClass: posixGroup
      cn: '${userid}'
      gidNumber: '${newGid}'
      ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/users_group_${userid}.ldif
            /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/users_group_${userid}.ldif
            fi

            # Add User to OpenLDAP
            if ! /usr/bin/sudo ldapsearch -x -b "uid=${userid},ou=Users,ou=People,${ldapDn}"; then
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
            for i in {1..10}; do
                echo "i: $i"
                if [[ -n $(/usr/bin/sudo -H -i -u ${userid} bash -c 'id' || true) ]]; then
                    break
                else
                    sleep 10
                fi
            done

            # Check new user user via getent and ldapsearch
            if [[ -z ${newGid} ]]; then
                /usr/bin/sudo getent passwd | grep ${userid} # Check ldap user is active, ie. shows up with getent
                /usr/bin/sudo getent group | grep ${userid} # Check ldap group is active, ie. shows up with getent
                newGid=$(id -g ${userid})
            else
                /usr/bin/sudo getent passwd | grep ${newGid} # Check ldap user is active, ie. shows up with getent
                /usr/bin/sudo getent group | grep ${newGid} # Check ldap group is active, ie. shows up with getent
            fi
            /usr/bin/sudo ldapsearch -x -b "ou=People,${ldapDn}"

            # Create "groupOfNames" group for Keycloak if it does not already exist
            kcadminGroupExists=$(/usr/bin/sudo ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "${ldapDn}" cn=kcadmins 2> /dev/null)
            if [[ -z ${kcadminGroupExists} ]]; then
                # Create kcadmins group with new user
                echo '''
        dn: cn=kcadmins,ou=Groups,ou=People,'${ldapDn}'
        objectClass: groupOfNames
        cn: kcadmins
        member: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | /usr/bin/sudo tee /etc/ldap/create-groupOfNames-group.ldif
                /usr/bin/sudo ldapadd -D "cn=admin,${ldapDn}" -w "${ldapAdminPassword}" -H ldapi:/// -f /etc/ldap/create-groupOfNames-group.ldif
            else
                if ! /usr/bin/sudo ldapsearch -x -b "cn=kcadmins,ou=Groups,ou=People,${ldapDn}" '(&(objectClass=groupOfNames)(member=uid='${userid}',ou=Users,ou=People,'${ldapDn}'))' | grep -q ^dn:; then
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
            /usr/bin/sudo ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "${ldapDn}" memberOf 2> /dev/null | grep memberOf

            # Give user full sudo priviliges
            printf "${userid}        ALL=(ALL)       NOPASSWD: ALL\n" | /usr/bin/sudo tee -a /etc/sudoers

        fi

        # Set default keyboard language as per users.json
        keyboardLanguages=""
        availableLanguages="us de gb fr it es"
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
        Exec=setxkbmap ${keyboardLanguages} -option grp:alt_shift_toggle
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
        newGid=$(id -g ${userid}) # In case script is re-run and the variable not set as a result
        for i in {1..10}; do
            echo "i: $i"
            /usr/bin/sudo chown -f -R ${newGid}:${newGid} /home/${userid} || true
            if [[ $(stat -c '%u' /home/${userid} || true) -eq ${newGid} ]]; then
                break
            else
                sleep 10
            fi
        done

        # Add KX.AS.CODE Root CA cert to Chrome CA Store
        if /usr/bin/sudo test ! -f /home/${userid}/.pki/nssdb; then
            /usr/bin/sudo rm -rf /home/${userid}/.pki
            mkdir -p /home/${userid}/.pki/nssdb/
            chown -R ${newGid}:${newGid} /home/${userid}/.pki
            /usr/bin/sudo -H -i -u ${userid} bash -c "certutil -N --empty-password -d sql:/home/${userid}/.pki/nssdb"
            /usr/bin/sudo -H -i -u ${userid} bash -c "/usr/local/bin/trustKXRootCAs.sh"
            /usr/bin/sudo -H -i -u ${userid} bash -c "certutil -L -d sql:/home/${userid}/.pki/nssdb"
        fi

        # Create SSH key kx.hero user
        if /usr/bin/sudo test ! -f /home/${userid}/.ssh/id_rsa; then
            /usr/bin/sudo chmod 700 /home/${userid}/.ssh
            /usr/bin/sudo -H -i -u ${userid} bash -c "yes | ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${userid}/.ssh/id_rsa -N ''"
        fi

        # Add desktop customization script to new users autostart-scripts folder
        if /usr/bin/sudo test ! -f /home/${userid}/.config/autostart-scripts/showWelcome.sh; then
            /usr/bin/sudo mkdir -p /home/${userid}/.config/autostart-scripts
            /usr/bin/sudo cp -f ${installationWorkspace}/showWelcome.sh /home/${userid}/.config/autostart-scripts
            /usr/bin/sudo chmod -R 755 /home/${userid}/.config/autostart-scripts
            /usr/bin/sudo chown -R ${userid}:${userid} /home/${userid}/.config/autostart-scripts
        fi

    if checkApplicationInstalled "keycloak" "core"; then

        if /usr/bin/sudo test ! -f /home/${userid}/.kube/config; then
            # Create Kubeconfig file
            /usr/bin/sudo mkdir -p /home/${userid}/.kube
            /usr/bin/sudo cat /etc/kubernetes/admin.conf | sed '/users:/,$d' | sed 's/kubernetes-admin/oidc/g' | /usr/bin/sudo tee /home/${userid}/.kube/config
            /usr/bin/sudo chown -R ${userid}:${userid} /home/${userid}/.kube
            /usr/bin/sudo chmod 600 /home/${userid}/.kube/config
            # Enable Keycloak OIDC for new user
            /usr/bin/sudo -H -i -u ${userid} bash -c "${installationWorkspace}/client-oidc-setup.sh"
            /usr/bin/sudo -H -i -u ${userid} bash -c "kubectl config set-context --current --user=oidc"
        fi

        # Source Keycloak Environment
        sourceKeycloakEnvironment

        # Call function to login to Keycloak
        keycloakLogin

        # Get Keycloak User Id
        export kcUserId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
            ${kcAdmCli} get users -r ${kcRealm} -q username=${userid} | jq -r '.[].id')

        # Create K8s cluster role binding for OIDC user if it does not exist
        /usr/bin/sudo kubectl get clusterrolebinding oidc-cluster-admin-${userid} || \
        /usr/bin/sudo kubectl create clusterrolebinding oidc-cluster-admin-${userid} --clusterrole=cluster-admin --user='https://keycloak.'${baseDomain}'/auth/realms/'${kcRealm}'#'${kcUserId}''

    else

      if [[ "${kubeOrchestrator}" == "k3s" ]]; then
        export kubeConfigFile=/etc/rancher/k3s/k3s.yaml
      else
        export kubeConfigFile=/etc/kubernetes/admin.conf
      fi

      /usr/bin/sudo -H -i -u ${userid} sh -c "mkdir -p /home/${userid}/.kube"
      /usr/bin/sudo cp -f ${kubeConfigFile} /home/${userid}/.kube/config
      
      # Ensure user has correct access permissions to .kube/config file
      /usr/bin/sudo chmod 600 /home/${userid}/.kube/config
      /usr/bin/sudo chown ${userid}:${userid}/.kube/config


      if [[ -z $(cat /home/${userid}/.bashrc | grep KUBECONFIG) ]]; then
          echo "export KUBECONFIG=/home/${userid}/.kube/config" | /usr/bin/sudo tee -a /home/${userid}/.bashrc /home/${userid}/.zshrc
      fi

    fi

    # Ensure user has correct access permissions to desktop files
    /usr/bin/sudo chmod 755 /home/${userid}/*.desktop
    /usr/bin/sudo chown ${userid}:${userid}/*.desktop

    # Initialize gnupg for new user to use with GoPass
    gnupgInitializeUser "${userid}" "${generatedPassword}"

        # Create and configure XRDP connection in Guacamole database
        if [[ -z $(/usr/bin/sudo su - postgres -c "psql -t -U postgres -d guacamole_db -c \"select name FROM guacamole_entity WHERE name = '${userid}' AND guacamole_entity.type = 'USER';\"") ]]; then
        echo """
    INSERT INTO guacamole_entity (name, type) VALUES ('${userid}', 'USER');
    INSERT INTO guacamole_user (entity_id, password_hash, password_salt, password_date)
    SELECT
        entity_id,
        decode('CA458A7D494E3BE824F5E1E175A1556C0F8EEF2C2D7DF3633BEC4A29C4411960', 'hex'),  -- '${generatedPassword}'
        decode('FE24ADC5E11E2B25288D1704ABE67A79E342ECC26064CE69C5B3177795A82264', 'hex'),
        CURRENT_TIMESTAMP
    FROM guacamole_entity WHERE name = '${userid}' AND guacamole_entity.type = 'USER';

    -- Grant admin permission to read/update/administer self
    INSERT INTO guacamole_user_permission (entity_id, affected_user_id, permission)
    SELECT guacamole_entity.entity_id, guacamole_user.user_id, permission::guacamole_object_permission_type
    FROM (
        VALUES
            ('${userid}', '${userid}', 'READ'),
            ('${userid}', '${userid}', 'UPDATE'),
            ('${userid}', '${userid}', 'ADMINISTER')
    ) permissions (username, affected_username, permission)
    JOIN guacamole_entity          ON permissions.username = guacamole_entity.name AND guacamole_entity.type = 'USER'
    JOIN guacamole_entity affected ON permissions.affected_username = affected.name AND guacamole_entity.type = 'USER'
    JOIN guacamole_user            ON guacamole_user.entity_id = affected.entity_id;
    """ | /usr/bin/sudo su - postgres -c "psql -U postgres -d guacamole_db" -

        # Create and configure XRDP connection in Guacamole database
        echo """

    INSERT INTO public.guacamole_connection_group_permission(entity_id, connection_group_id, permission)
    VALUES (
      (select entity_id from guacamole_entity where name = '${userid}'),
      (select connection_group_id from guacamole_connection_group where connection_group_name = 'kx-as-code'),
      'READ'
    );

    INSERT INTO public.guacamole_connection_permission(entity_id, connection_id, permission)
    VALUES (
      (select entity_id from guacamole_entity where name = '${userid}'),
      (select connection_id from guacamole_connection where connection_name = 'rdp'),
      'READ'
    );

    """ | /usr/bin/sudo su - postgres -c "psql -U postgres -d guacamole_db" -
    fi

    done
fi
