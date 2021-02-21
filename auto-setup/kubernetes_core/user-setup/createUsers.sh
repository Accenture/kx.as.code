#!/bin/bash -x

export numUsersToCreate=$(jq -r '.config.additionalUsers[].firstname' ${installationWorkspace}/autoSetup.json | wc -l)
export ldapDnFirstPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f1 -d',')
export ldapDnSecondPart=$(sudo slapcat | grep dn | head -1 | sed 's/dn: //g' | sed 's/dc=//g' | cut -f2 -d',')
export kcRealm=${ldapDnFirstPart}
export ldapDn="dc=${ldapDnFirstPart},dc=${ldapDnSecondPart}"
export kcInternalUrl=http://localhost:8080
export kcBinDir=/opt/jboss/keycloak/bin/
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')

if [[ ${numUsersToCreate} -ne 0 ]]; then
  for i in $(seq 0 $(((numUsersToCreate-1))))
  do
    echo "i: $i"
    firstname=$(jq -r '.config.additionalUsers['$i'].firstname' ${installationWorkspace}/autoSetup.json)
    surname=$(jq -r '.config.additionalUsers['$i'].surname' ${installationWorkspace}/autoSetup.json)
    email=$(jq -r '.config.additionalUsers['$i'].email' ${installationWorkspace}/autoSetup.json)

    firstnameSubstringLength=$((8-${#surname}))

    if [[ ${firstnameSubstringLength} -le 0 ]]; then
      firstnameSubstringLength=1
    fi
      echo $firstnameSubstringLength
      userid="$(echo ${surname,,} | cut -c1-7)$(echo ${firstname,,} | cut -c1-${firstnameSubstringLength})"

    echo "${userid} ${firstname} ${surname} ${email}"

    if ! id -u ${userid} > /dev/null 2>&1; then

      if [ ! -f /home/${userid}/.ssh/id_rsa ]; then
        # Create the kx.hero user ssh directory.
        sudo mkdir -pm 700 /home/${userid}/.ssh

        # Ensure the permissions are set correct
        sudo chown -R ${userid}:${userid} /home/${userid}/.ssh

        # Create SSH key kx.hero user
        sudo chmod 700 /home/${userid}/.ssh
        yes | sudo -u ${userid} ssh-keygen -f ssh-keygen -m PEM -t rsa -b 4096 -q -f /home/${userid}/.ssh/id_rsa -N ''
      fi

      # Generate password
      generatedPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8};echo;)
      echo "${userid}:${generatedPassword}" | sudo tee -a ${sharedKxHome}/.users

      # Determine UID/GID for new user
      lastLdapGid=$(sudo ldapsearch -x -b "ou=People,${ldapDn}" | grep gidNumber | sed 's/gidNumber: //' | sort | uniq | tail -1)
      echo "Last GID: $lastLdapGid"
      newGid=$(( $lastLdapGid + 1 ))
      echo "New GID: $newGid"
 
       # Add User Group to OpenLDAP for Linux login
      echo '''
      dn: cn='${userid}',ou=Groups,ou=People,'${ldapDn}'
      objectClass: posixGroup
      cn: '${userid}'
      gidNumber: '${newGid}'
      ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | sudo tee /etc/ldap/users_group_${userid}.ldif
      sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/users_group_${userid}.ldif

      # Add User to OpenLDAP
      echo '''
      dn: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
      objectClass: top
      objectClass: account
      objectClass: posixAccount
      objectClass: shadowAccount
      cn: '${userid}'
      uid: '${userid}'
      uidNumber: '${newGid}'
      gidNumber: '${newGid}'
      homeDirectory: /home/'${userid}'
      userPassword: '${generatedPassword}'
      loginShell: /bin/zsh
      ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | sudo tee /etc/ldap/new_user_${userid}.ldif
      sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/new_user_${userid}.ldif

      # Check Result
      sudo ldapsearch -x -b "ou=People,${ldapDn}"

      # Create "groupOfNames" group for Keycloak if it does not already exist
      kcadminGroupExists=$(sudo ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "${ldapDn}" cn=kcadmins 2>/dev/null)
      if [[ -z ${kcadminGroupExists} ]]; then
        # Create kcadmins group with new user
        echo '''
        dn: cn=kcadmins,ou=Groups,ou=People,'${ldapDn}'
        objectClass: groupOfNames
        cn: kcadmins
        member: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | sudo tee /etc/ldap/create-groupOfNames-group.ldif
        sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/create-groupOfNames-group.ldif
      else
        # Add user to existing kcadmins group
        echo '''
        dn: uid='${userid}',ou=Users,ou=People,'${ldapDn}'
        changetype: modify
        add: memberOf
        memberOf: cn=kcadmins,ou=Groups,ou=People,'${ldapDn}'
        ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | sudo tee /etc/ldap/add_user_${userid}_to_kcadmins.ldif
        sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}"  -H ldapi:/// -f /etc/ldap/add_user_${userid}_to_kcadmins.ldif
      fi

      # Check user was added successfully
      ldapsearch -H ldapi:/// -Y EXTERNAL -LLL -b "${ldapDn}" memberOf 2>/dev/null | grep memberOf

      # Give user root priviliges
      printf "${userid}        ALL=(ALL)       NOPASSWD: ALL\n" | sudo tee -a /etc/sudoers

    fi

    sudo mkdir -p /home/${userid}/Desktop
    sudo ln -s ${sharedGitHome}/kx.as.code /home/${userid}/Desktop/"KX.AS.CODE Source";

    sudo cp -rf /usr/share/kx.as.code/skel/* /home/${userid}/
    sudo cp -rf /usr/share/kx.as.code/skel/.* /home/${userid}/
    sudo rm -rf /home/${userid}/.cache/sessions

    echo '''
    [Desktop Entry]
    Type=Application
    Name=Welcome-Message
    Exec=/usr/share/kx.as.code/showWelcome.sh
    ''' | sudo tee /home/${userid}/.config/autostart/show-welcome.desktop
    sudo chmod 755 /home/${userid}/.config/autostart/show-welcome.desktop

    # Configure Typora with content list and hidden menu
    sudo mkdir -p /home/${userid}/.config/Typora/
    echo "7b22696e697469616c697a655f766572223a22302e392e3936222c226c696e655f656e64696e675f63726c66223a66616c73652c227072654c696e65627265616b4f6e4578706f7274223a747275652c2275756964223a2264336161313134302d623865362d346661612d623563372d373165353233383135313864222c227374726963745f6d6f6465223a747275652c22636f70795f6d61726b646f776e5f62795f64656661756c74223a747275652c226261636b67726f756e64436f6c6f72223a2223303030303030222c22736964656261725f746162223a226f75746c696e65222c22757365547265655374796c65223a66616c73652c2273686f77537461747573426172223a66616c73652c226c617374436c6f736564426f756e6473223a7b2266756c6c73637265656e223a66616c73652c226d6178696d697a6564223a66616c73652c2278223a3533362c2279223a3138322c227769647468223a3830302c22686569676874223a3730307d2c2269734461726b4d6f6465223a747275652c227468656d65223a226769746c61622e637373222c227072657365745f7370656c6c5f636865636b223a2264697361626c6564227d" | sudo tee /home/${userid}/.config/Typora/profile.data
    sudo mkdir -p /home/${userid}/.config/Typora/conf
    echo '''
    /** For advanced users. */
    {
      "defaultFontFamily": {
        "standard": null, //String - Defaults to "Times New Roman".
        "serif": null, // String - Defaults to "Times New Roman".
        "sansSerif": null, // String - Defaults to "Arial".
        "monospace": null // String - Defaults to "Courier New".
      },
      "autoHideMenuBar": true, //Boolean - Auto hide the menu bar unless the \`Alt\` key is pressed. Default is false.
    
      // Array - Search Service user can access from context menu after a range of text is selected. Each item is formatted as [caption, url]
      "searchService": [
        ["Search with Google", "https://google.com/search?q=%s"]
      ],
    
      // Custom key binding, which will override the default ones.
      "keyBinding": {
        // for example:
        // "Always on Top": "Ctrl+Shift+P"
      },
    
      "monocolorEmoji": false, //default false. Only work for Windows
      "autoSaveTimer" : 3, // Deprecidated, Typora will do auto save automatically. default 3 minutes
      "maxFetchCountOnFileList": 500,
      "flags": [] // default [], append Chrome launch flags, e.g: [["disable-gpu"], ["host-rules", "MAP * 127.0.0.1"]]
    }
    ''' | sudo tee /home/${userid}/.config/Typora/conf/conf.user.json

    echo '''
    [org.freedesktop.DisplayManager.AccountsService]
    BackgroundFile="/usr/share/backgrounds/background.jpg"

    [User]
    Session=
    XSession=xfce
    Icon=/usr/share/pixmaps/faces/digital_avatar.png
    SystemAccount=false

    [InputSource0]
    xkb=de
    ''' | sudo tee /var/lib/AccountsService/users/${userid}

    # Loop change ownership to wait for OpenLDAP user to be available for setting ownership
    for i in {1..10}
    do
      echo "i: $i"
      sudo chown -f -R ${userid}:${userid} /home/${userid} || true
      directoryOwnership=$(stat -c '%u' /home/${userid})
      if [[ ${directoryOwnership} -eq ${newGid} ]]; then
        break
      else
        sleep 10
      fi
    done

    # Add KX.AS.CODE Root CA cert to Chrome CA Store
    sudo rm -rf /home/${userid}/.pki
    mkdir -p /home/${userid}/.pki/nssdb/
    chown -R ${userid}:${userid} /home/${userid}/.pki
    sudo -H -i -u ${userid} sh -c "certutil -N --empty-password -d sql:/home/${userid}/.pki/nssdb"
    sudo -H -i -u ${userid} sh -c "/usr/local/bin/trustKXRootCAs.sh"
    sudo -H -i -u ${userid} sh -c "certutil -L -d sql:/home/${userid}/.pki/nssdb"

    # Set credential token in new Realm
    kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword} --client admin-cli

    # Enable Keycloak OIDC for new user
    sudo -H -i -u ${userid} sh -c "/usr/share/kx.as.code/Kubernetes/client-oidc-setup.sh"
    export kcUserId=$(kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} get users -r ${kcRealm} -q username=${userid} | jq -r '.[].id')
    sudo -H -i -u ${userid} sh -c  "kubectl config set-context --current --user=oidc"
    sudo kubectl create clusterrolebinding oidc-cluster-admin-${userid} --clusterrole=cluster-admin --user='https://keycloak.'${baseDomain}'/auth/realms/'${kcRealm}'#'${kcUserId}''
    sudo rm -f
  done
fi






