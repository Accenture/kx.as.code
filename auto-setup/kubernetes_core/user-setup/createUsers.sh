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

      sudo groupadd ${userid}
      sudo useradd ${userid} -g ${userid} -G sudo -d /home/${userid} -s /bin/zsh -m  -k /usr/share/kx.as.code/skel
      generatedPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)
      echo "${userid}:${generatedPassword}" | sudo chpasswd
      echo "${userid}:${generatedPassword}" | sudo tee -a /usr/share/kx.as.code/.users

      # Give user root priviliges
      printf "${userid}        ALL=(ALL)       NOPASSWD: ALL\n" | sudo tee -a /etc/sudoers

    fi

    sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/${userid}/Desktop/"KX.AS.CODE Source";

  done
fi






