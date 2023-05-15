checkApplicationInstalled() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  export componentName=${1}
  export componentInstallationFolder=${2}

  # Define component install directory
  local installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

  # Define location of metadata JSON file for component
  local componentToCheckMetadataJson=${installComponentDirectory}/metadata.json

  # URL Liveliness Healthcheck
  >&2 log_debug "Getting URL for \"${componentName}\" in \"${componentInstallationFolder}\" folder"
  local applicationUrl=$(cat ${componentToCheckMetadataJson} | jq -r '.urls[0]?.url?' | mo)
  local livelinessCheckData=$(cat ${componentToCheckMetadataJson} | jq -r '.urls[0]?.healthchecks?.liveliness?')
  local urlCheckPath=$(echo ${livelinessCheckData} | jq -r '.http_path')
  >&2 log_debug "Retrieved URL for checking application existence: \"${applicationUrl}${urlCheckPath}\""
  # Check if application URL exists. If 404 is returned, assumption is that it is not installed
  local http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath} || true)
  if [[ "${http_code}" == "404" ]]; then
    >&2 log_debug "Application \"${componentName}\" is not installed. Will skip next steps that relies on this application to be available"
    false
    return
  else
    >&2 log_debug "Application \"${componentName}\" is installed. Continuing with application specific next steps"
    true
    return
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}