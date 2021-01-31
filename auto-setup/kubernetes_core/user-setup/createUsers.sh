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
      sudo groupadd ${userid}
      sudo useradd ${userid} -g ${userid} -G sudo -d /home/${userid} -s /bin/zsh --create-home
      generatedPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)
      echo "${userid}:${generatedPassword}" | sudo chpasswd
      echo "${userid}:${generatedPassword}" | sudo tee -a /usr/share/kx.as.code/.users
    fi

    sudo ln -s ${SHARED_GIT_REPOSITORIES}/kx.as.code /home/${userid}/Desktop/"KX.AS.CODE Source";

  done
fi
