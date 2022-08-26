#!/bin/bash
set -euo pipefail

# Get hash passed in from the Jenkins based launcher
hash="$(/usr/bin/sudo cat /var/tmp/.hash)"

# Ensure no Windows characters blocking decryption
/usr/bin/sudo apt-get install dos2unix
/usr/bin/sudo dos2unix ${sharedKxHome}/.config/.vmCredentialsFile

# Loop through encrypted credentials file and load into GoPass
while IFS='' read -r credential || [[ -n "$credential" ]]; do
    name=$(echo ${credential} | cut -f 1 -d':')
    secret=$(echo ${credential} | cut -f 2 -d':')
    if [[ "${secret}" != '""' ]] && [[ "${secret}" != "" ]]; then
           decryptedSecret=$(echo "${secret}" | openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${hash} -d)
    else
           decryptedSecret=""
    fi
    pushPassword "${name}" "${decryptedSecret}" "base-user-${baseUser}"
done < "${sharedKxHome}/.config/.vmCredentialsFile"

# Cleanup files
/usr/bin/sudo rm -f cat /var/tmp/.hash
/usr/bin/sudo rm -f ${sharedKxHome}/.config/.vmCredentialsFile