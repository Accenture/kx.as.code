downloadFile() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  url="${1}"
  checksum="${2}"

  # Get filename from URL if not explicitly set as 3rd parameter
  if [[ $# -lt 3 ]]; then
    outputFilename="${installationWorkspace}/$(basename ${url})"
  else
    outputFilename="${3}"
  fi

  log_info "Downloading ${outputFilename} from ${url}"
  # Download file with subsequent checksum validation
  for i in {1..15}
  do
    /usr/bin/sudo curl -L --connect-timeout 5 \
      --retry 30 \
      --retry-all-errors \
      --retry-delay 15 \
      -o "${outputFilename}" \
      "${url}"

    checkResult=$(echo "${checksum}" "${outputFilename}" | sha256sum -c --quiet && echo "OK" || echo "NOK")
    echo "${checkResult}"
    if [[ "${checkResult}" == "OK" ]]; then
      log_info "Checksum of downloaded file ${outputFilename} OK"
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
