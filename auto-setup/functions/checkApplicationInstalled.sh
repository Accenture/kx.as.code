checkApplicationInstalled() {

  local appComponentName=${1}
  local appComponentInstallationFolder=${2}

  # Define component install directory
  local appInstallComponentDirectory=${autoSetupHome}/${appComponentInstallationFolder}/${appComponentName}

  # Define location of metadata JSON file for component
  local appComponentToCheckMetadataJson=${appInstallComponentDirectory}/metadata.json

  # URL Liveliness Healthcheck
  >&2 log_debug "Getting URL for \"${appComponentName}\" in \"${appComponentInstallationFolder}\" folder"
  local applicationUrlToCheck="https://${appComponentName}.${baseDomain}"
  local appLivelinessCheckData=$(cat ${appComponentToCheckMetadataJson} | jq -r '.urls[0]?.healthchecks?.liveliness?')
  local appUrlCheckPath=$(echo ${appLivelinessCheckData} | jq -r '.http_path')
  >&2 log_debug "Retrieved URL for checking application existence: \"${applicationUrlToCheck}${appUrlCheckPath}\""
  # Check if application URL exists. If 404 is returned, assumption is that it is not installed
  local http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${applicationUrlToCheck}${appUrlCheckPath} || true)
  if [[ "${http_code}" == "404" ]] || [[ -z "${http_code}" ]] || [[ "${http_code}" == "000" ]] || [[ "${http_code}" == "502" ]] || [[ "${http_code}" == "503" ]]; then
    >&2 log_debug "Application \"${appComponentName}\" is not installed or in error. Will skip next steps that relies on this application to be available"
    false
    return
  else
    >&2 log_debug "Application \"${appComponentName}\" is installed. Continuing with application specific next steps"
    true
    return
  fi

}
