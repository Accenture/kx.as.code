#!/bin/bash

if [[ -f /var/tmp/.hash ]] && [[ -f ${sharedKxHome}/.config/.vmCredentialsFile ]]; then
       # Get hash passed in from the Jenkins based launcher
       hash="$(/usr/bin/sudo cat /var/tmp/.hash)"

       # Check has is valid
       if [[ -n ${hash} ]] && [[ "${hash}" != "{{hash}}" ]]; then

       # Ensure no Windows characters blocking decryption
       /usr/bin/sudo apt-get install dos2unix
       /usr/bin/sudo dos2unix ${sharedKxHome}/.config/.vmCredentialsFile

       # Loop through encrypted credentials file and load into GoPass
       while IFS='' read -r credential || [[ -n "$credential" ]]; do
       name=$(echo ${credential} | cut -f 1 -d':')
       secret=$(echo ${credential} | cut -f 2 -d':')
       if [[ "${secret}" != '""' ]] && [[ "${secret}" != "" ]]; then
              decryptedSecret=$(echo "${secret}" | openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${hash} -d)
              cleanedSecret=$(cleanOutput "${decryptedSecret}")
       else
              decryptedSecret=""
       fi
       pushPassword "${name}" "${cleanedSecret}" "base-technical-credentials"
       done < "${sharedKxHome}/.config/.vmCredentialsFile"

       # Cleanup files
       /usr/bin/sudo rm -f /var/tmp/.hash
       /usr/bin/sudo rm -f ${sharedKxHome}/.config/.vmCredentialsFile
  else
    log_warn "The has used to decrypt the initial set of uploaded base password was either empty or not valid. Skipping the initial automated upload of credentials post GoPass installation"
  fi
fi