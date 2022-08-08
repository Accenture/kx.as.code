checkApplicationInstalled() {

  componentName=${1}
  componentInstallationFolder=${2}

  # Define component install directory
  installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

  # Define location of metadata JSON file for component
  componentMetadataJson=${installComponentDirectory}/metadata.json

  # URL Liveliness Healthcheck
  applicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.url?' | mo)
  livelinessCheckData=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.healthchecks?.liveliness?')
  urlCheckPath=$(echo ${livelinessCheckData} | jq -r '.http_path')

  # Check if application URL exists. If 404 is returned, assumption is that it is not installed
  http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath} || true)
  if [[ "${http_code}" == "404" ]]; then
    false
  else
    true
  fi

}