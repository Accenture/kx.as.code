checkApplicationInstalled() {

  componentNameToCheck=${1}
  componentToCheckInstallationFolder=${2}

  # Define component install directory
  installComponentDirectory=${autoSetupHome}/${componentToCheckInstallationFolder}/${componentNameToCheck}

  # Define location of metadata JSON file for component
  componentToCheckMetadataJson=${installComponentDirectory}/metadata.json

  # URL Liveliness Healthcheck
  applicationToCheckUrl=$(cat ${componentToCheckMetadataJson} | jq -r '.urls[0]?.url?' | mo)
  livelinessCheckData=$(cat ${componentToCheckMetadataJson} | jq -r '.urls[0]?.healthchecks?.liveliness?')
  urlCheckPath=$(echo ${livelinessCheckData} | jq -r '.http_path')

  # Check if application URL exists. If 404 is returned, assumption is that it is not installed
  http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${applicationToCheckUrl}${urlCheckPath} || true)
  if [[ "${http_code}" == "404" ]]; then
    echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] Application \"${componentNameToCheck}\" is not installed. Will skip next steps that relies on this application to be available" >&2
    false
    return
  else
    echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] Application \"${componentNameToCheck}\" is installed. Continuing with application specific next steps" >&2
    true
    return
  fi

}