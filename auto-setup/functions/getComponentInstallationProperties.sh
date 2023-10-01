getComponentInstallationProperties() {

  # Define component install directory
  export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

  # Define location of metadata JSON file for component
  export componentMetadataJson=${installComponentDirectory}/metadata.json

  # Retrieve namespace from component's metadata.json
  export namespace=$(cat ${componentMetadataJson} | jq -r '.namespace? | select(.!=null)' | sed 's/_/-/g' | tr '[:upper:]' '[:lower:]') # Ensure DNS compatible name

  # Get installation type (valid values are script, helm or argocd) and path to scripts
  export installationType=$(cat ${componentMetadataJson} | jq -r '.installation_type | select(.!=null)')

  # Will restrict ingress access to component's URL to local subnet only. Access from outside VM will be blocked
  export restrictIngressAccess=$(cat ${componentMetadataJson} | jq -r '.restrictIngressAccess | select(.!=null)')

  # Get application URL & domain
  export applicationUrl=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.url? | select(.!=null)')
  export applicationDomain=$(echo ${applicationUrl} | sed 's/https:\/\///g')

  # Get desktop shortcut variables
  export shortcutText=$(cat ${componentMetadataJson} | jq -r '.shortcut_text | select(.!=null)')
  export shortcutIcon=$(cat ${componentMetadataJson} | jq -r '.shortcut_icon | select(.!=null)')

  # Set application environment variables if set in metadata.json
  if [[ -n "$(cat ${componentMetadataJson} | jq -r '.environment_variables | select(.!=null)')" ]]; then
    log_info "Processing environment variables for component ${componentName}"

    applicationEnvironmentVariablesJson=$(cat ${componentMetadataJson} | jq -r '.environment_variables | select(.!=null)')
    applicationEnvironmentVariables=$(echo ${applicationEnvironmentVariablesJson} | jq -r 'keys_unsorted | .[]')

    for applicationEnvironmentVariable in ${applicationEnvironmentVariables}
    do
        # Export variable with mustach variable replacement
        export ${applicationEnvironmentVariable}="$(echo "$applicationEnvironmentVariablesJson" | jq -r '.'${applicationEnvironmentVariable}'' | mo)"
        # Export variable with environment variable replacement
        export ${applicationEnvironmentVariable}="$(eval echo "${!applicationEnvironmentVariable}")"
        # Log for debugging purposes
        log_debug "Export environment variable: ${applicationEnvironmentVariable}=\"${!applicationEnvironmentVariable}\""
    done

  else
    log_info "No environment variables defined for ${componentName}"
  fi

}
