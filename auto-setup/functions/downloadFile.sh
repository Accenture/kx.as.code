downloadFile() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local url="${1}"
  local checksum="${2}"
  local targetPath="${3-}"
  local user="${4-}"
  local password="${5-}"

  # Set authentication if passed into function
  if [[ -n ${user} ]] && [[ -n ${password} ]]; then
    local authOption="--user ${user}:${password}"
  else
    local authOption=""
  fi

  # Get filename from URL if target path not provided, and use default workspace
  if [[ $(echo ${targetPath} | awk -F/ '{ print NF - 1 }') -gt 0 ]]; then
    local outputFilename="${targetPath}"
  else
    local outputFilename="${installationWorkspace}/$(basename ${url})"
  fi

  # Exit the script if the file already downloaded successfully in the past
  if [[ -f ${outputFilename} ]]; then
    local checkResult=$(echo "${checksum}" "${outputFilename}" | sha256sum -c --quiet && echo "OK" || echo "NOK")
    echo "${checkResult}"
    if [[ "${checkResult}" == "OK" ]]; then
      log_info "Checksum of prevously downloaded file ${outputFilename} OK. Exiting with RC=0 "
      return 0
    else
      # Remove file that hasn't passed the checksum validation
      log_warn "Removing previously downloaded ${outputFilename} as checksum did not match. Will re-download."
      /usr/bin/sudo rm -f ${outputFilename}
    fi
  fi

  log_info "Downloading ${outputFilename} from ${url}"
  # Download file with subsequent checksum validation
  local i
  for i in {1..15}
  do
    /usr/bin/sudo curl -L --connect-timeout 5 \
      --retry 30 \
      --retry-all-errors \
      --retry-delay 15 \
      -o "${outputFilename}" \
      ${authOption} "${url}"

    if [[ "${checksum}" != "not-applicable" ]]; then
      local checkOutput=$(echo "${checksum}" "${outputFilename}" | sha256sum -c --quiet && echo "OK" || echo "NOK")
      if [[ "${checkOutput}" == "OK" ]]; then
        local checkResult=${checkOutput}
      else
        local checkResult=$(echo ${checkOutput} | awk '{print $3}')
      fi
    fi

    echo "${checkResult}"
    if [[ "${checkResult}" == "OK" ]]; then
      log_info "Checksum of downloaded file ${outputFilename} OK"
      return 0
      break
    fi
    sleep 15
  done

  # Finally return with an error return code if download not OK [NOK]
  if [[ "${checkResult}" == "NOK" ]]; then
    log_error "Checksum of downloaded file ${outputFilename} NOK"
    exit 1
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
