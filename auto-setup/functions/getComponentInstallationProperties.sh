getComponentInstallationProperties() {

  # Define component install directory
  export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

  # Define location of metadata JSON file for component
  export componentMetadataJson=${installComponentDirectory}/metadata.json

  # Retrieve namespace from component's metadata.json
  export namespace=$(cat ${componentMetadataJson} | jq -r '.namespace?' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]') # Ensure DNS compatible name

  # Get installation type (valid values are script, helm or argocd) and path to scripts
  export installationType=$(cat ${componentMetadataJson} | jq -r '.installation_type')

  # Get application URL & domain
  export applicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.url?')
  export applicationDomain=$(echo ${applicationUrl} | sed 's/https:\/\///g')

  # Set application environment variables if set in metadata.json
  if [[ "$(cat ${componentMetadataJson} | jq -r '.environment_variables')" != "null" ]]; then
    log_info "Processing environment variables for component ${componentName}"
    export applicationEnvironmentVariables=$(cat ${componentMetadataJson} | jq -r '.environment_variables | to_entries|map("\(.key)=\(.value|tostring)")|.[] ')
    if [[ -n ${applicationEnvironmentVariables} ]]; then
        for environmentVariable in ${applicationEnvironmentVariables}; do
            export ${environmentVariable}
        done
    fi
  else
    log_info "No environment variables defined for ${componentName}"
  fi

}
