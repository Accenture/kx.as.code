####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
clearSensitiveDataFromLog() {

  #set +x  # Ensure passwords not re-exposed during cleanup

  local logFile="${1}"

  if [[ -n ${logFile} ]] && [[ -f ${logFile} ]]; then

    local tmpIdentifier=$(echo $RANDOM | base64 | head -c 20; echo)
    cat ${logFile} | grep -v grep | grep -v '\*\*\*\*\*\*\*\*' | grep -o -P -i '(?<=password=).*(?=)' | grep -v '\${' | awk {'print $1'} | sort | uniq | /usr/bin/sudo tee /tmp/.sedTmp_${tmpIdentifier}

    local foundPasswords=$(cat /tmp/.sedTmp_${tmpIdentifier}) && /usr/bin/sudo rm -f /tmp/.sedTmp_${tmpIdentifier}

    for foundPassword in ${foundPasswords}
    do
        sed -i '/'${foundPassword}'/ s//********/g' ${logFile} || \
        sed -i "/${foundPassword}/ s//********/g" ${logFile}
    done

  fi

  #set -x  # Re-enable verbose logging

}
