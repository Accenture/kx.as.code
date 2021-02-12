#!/bin/bash -x

export SKELDIR=/usr/share/kx.as.code/skel
numUsersToCreate=$(jq -r '.config.additionalUsers[].firstname' ${installationWorkspace}/autoSetup.json | wc -l)

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

      # Generatw password
      generatedPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)
      echo "${userid}:${generatedPassword}" | sudo tee -a /usr/share/kx.as.code/.users

      # Determine UID/GID for new user
      lastLdapGid=$(sudo ldapsearch -x -b "ou=People,${ldapDn}" | grep gidNumber | sed 's/gidNumber: //' | sort | uniq | tail -1)
      echo "Last GID: $lastLdapGid"
      newGid=$(( $lastLdapGid + 1 ))
      echo "New GID: $newGid"
 
       # Add User Group to OpenLDAP
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
      userPassword: '${vmPassword}'
      loginShell: /bin/zsh
      ''' | sed -e 's/^[ \t]*//' | sed '/^$/d' | sudo tee /etc/ldap/new_user_${userid}.ldif
      sudo ldapadd -D "cn=admin,${ldapDn}" -w "${vmPassword}" -H ldapi:/// -f /etc/ldap/new_user_${userid}.ldif

      # Check Result
      sudo ldapsearch -x -b "ou=People,${ldapDn}"

      # Give user root priviliges
      printf "${userid}        ALL=(ALL)       NOPASSWD: ALL\n" | sudo tee -a /etc/sudoers

    fi

    sudo mkdir -p /home/${userid}/Desktop
    sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/${userid}/Desktop/"KX.AS.CODE Source";

    # Loop change ownership to allow user to be available for setting ownership
    for i in {1..5}
    do
      sudo chown -R ${userid}:${userid} /home/${userid} || true
      directoryOwnership=$(ls -l /home/${userid} | grep ${userid})
      if [[ -z ${directoryOwnership} ]]; then
        sleep 5
      else
        break
      fi
    done

  done
fi






