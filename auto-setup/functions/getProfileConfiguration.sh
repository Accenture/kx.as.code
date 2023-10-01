getProfileConfiguration() {

  # Get configs from profile-config.json
  export virtualizationType=$(cat ${profileConfigJsonPath} | jq -r '.config.virtualizationType | select(.!=null)')
  export standaloneMode=$(cat ${profileConfigJsonPath} | jq -r '.config.standaloneMode | select(.!=null)')
  export baseIpType=$(cat ${profileConfigJsonPath} | jq -r '.config.baseIpType | select(.!=null)')
  export dnsResolution=$(cat ${profileConfigJsonPath} | jq -r '.config.dnsResolution.resolutionType | select(.!=null)')
  export dnsForwarding=$(cat ${profileConfigJsonPath} | jq -r '.config.dnsResolution.dnsForwarding | select(.!=null)')
  export kubeOrchestrator=$(cat ${profileConfigJsonPath} | jq -r '.config.kubeOrchestrator | select(.!=null)')
  export updateSourceOnStart=$(cat ${profileConfigJsonPath} | jq -r '.config.updateSourceOnStart | select(.!=null)')

  if [[ "${baseIpType}" == "static" ]] || [[ "${dnsResolution}" == "hybrid" ]]; then
    export fixedNicConfigDns1=$(cat ${profileConfigJsonPath} | jq -r '.config.dnsResolution.dns1 | select(.!=null)')
    export fixedNicConfigDns2=$(cat ${profileConfigJsonPath} | jq -r '.config.dnsResolution.dns2 | select(.!=null)')
  fi

  if [[ ${baseIpType} == "static" ]]; then
    # Get fixed IPs if defined
    export fixedIpHosts=$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses | keys[]')
    for fixIpHost in ${fixedIpHosts}; do
      fixIpHostVariableName=$(echo ${fixIpHost} | sed 's/-/__/g')
      export ${fixIpHostVariableName}_IpAddress="$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
      if [[ ${fixIpHost} == "kx-main1" ]]; then
        export mainIpAddress="$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
      fi
    done
    export fixedNicConfigGateway=$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.gateway | select(.!=null)')
  else
    export mainIpAddress=$(ip a s ${netDevice} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
  fi

  export environmentPrefix=$(cat ${profileConfigJsonPath} | jq -r '.config.environmentPrefix | select(.!=null)')
  if [ -z ${environmentPrefix} ]; then
    export baseDomain=$(cat ${profileConfigJsonPath} | jq -r '.config.baseDomain | select(.!=null)')
  else
    if [[ "${environmentPrefix}" == "ownerId" ]]; then
      export ownerId=$(getOwnerId)
      export environmentPrefix=${ownerId}
      export baseDomain="${ownerId}.$(cat ${profileConfigJsonPath} | jq -r '.config.baseDomain | select(.!=null)')"
    else
      export baseDomain="${environmentPrefix}.$(cat ${profileConfigJsonPath} | jq -r '.config.baseDomain | select(.!=null)')"
    fi
  fi

  # For use in tools that require and organization name, where "." cause an error
  export baseDomainWithHyphens=$(echo ${baseDomain} | sed 's/\./-/g')

  export numKxMainNodes=$(cat ${profileConfigJsonPath} | jq -r '.vm_properties.main_node_count | select(.!=null)')
  if [[ "${numKxMainNodes}" = "null" ]]; then
    export numKxMainNodes="1"
  fi

  export defaultKeyboardLanguage=$(cat ${profileConfigJsonPath} | jq -r '.config.defaultKeyboardLanguage | select(.!=null)')
  export baseUser=$(getOwnerId)

  # If deployed to public cloud, force password change for security reasons, to avoid all VM owners having the same base password, especially when doing a mass deployment
  if [[ "${virtualizationType}" == "public-cloud" ]]; then
    # Use GoPass only if already installed, else generate password directly, and it will later be added to GoPass
    if [[ -f /usr/bin/gopass ]]; then
      # Get password from GoPass
      log_debug "Getting existing credential for \"${baseUser}\" from Gopass"
      export basePassword=$(managedPassword "user-${baseUser}-password" "users")
    else
      if id ${baseUser}; then
        # Generate new password
        log_debug "Setting new password for \"${baseUser}\""
        export basePassword=$(generatePassword)
        # Update user system password
        /usr/bin/sudo usermod --password $(echo "${basePassword}" | openssl passwd -1 -stdin) "${baseUser}"
      fi
    fi
  else
    export basePassword=$(cat ${profileConfigJsonPath} | jq -r '.config.basePassword | select(.!=null)')
  fi

  export baseIpRangeStart=$(cat ${profileConfigJsonPath} | jq -r '.config.baseIpRangeStart | select(.!=null)')
  export baseIpRangeEnd=$(cat ${profileConfigJsonPath} | jq -r '.config.baseIpRangeEnd | select(.!=null)')
  export logLevel=$(cat ${profileConfigJsonPath} | jq -r '.config.logLevel | select(.!=null)')
  export metalLbIpRangeStart=$(cat ${profileConfigJsonPath} | jq -r '.config.metalLbIpRange.ipRangeStart | select(.!=null)')
  export metalLbIpRangeEnd=$(cat ${profileConfigJsonPath} | jq -r '.config.metalLbIpRange.ipRangeEnd | select(.!=null)')
  export sslProvider=$(cat ${profileConfigJsonPath} | jq -r '.config.sslProvider | select(.!=null)')
  export sslDomainAdminEmail=$(cat ${profileConfigJsonPath} | jq -r '.config.sslDomainAdminEmail | select(.!=null)')
  export letsEncryptEnvironment=$(cat ${profileConfigJsonPath} | jq -r '.config.letsEncryptEnvironment | select(.!=null)')
  # Get proxy settings
  export httpProxySetting=$(cat ${profileConfigJsonPath} | jq -r '.config.proxy_settings.http_proxy | select(.!=null)')
  export httpsProxySetting=$(cat ${profileConfigJsonPath} | jq -r '.config.proxy_settings.https_proxy | select(.!=null)')
  export noProxySetting=$(cat ${profileConfigJsonPath} | jq -r '.config.proxy_settings.no_proxy | select(.!=null)')

  # Get default applications for certain services
  ## Git
  export defaultGitPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.git | select(.!=null)')
  export gitDomain="$(cat ${autoSetupHome}/${defaultGitPath}/metadata.json | jq -r '.name' | sed 's/-ce//g').${baseDomain}"
  export gitUrl="https://${gitDomain}"
  ## OAUTH
  export defaultOauthPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.oauth | select(.!=null)')
  export oauthDomain="$(cat ${autoSetupHome}/${defaultOauthPath}/metadata.json | jq -r '.name').${baseDomain}"
  export oauthUrl="https://${oauthDomain}"
  ## ChatOps
  export defaultChatopsPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.chatops | select(.!=null)')
  export chatopsDomain="$(cat ${autoSetupHome}/${defaultChatopsPath}/metadata.json | jq -r '.name').${baseDomain}"
  export chatopsUrl="https://${chatopsDomain}"
  ## Docker Registry
  export defaultDockerRegistryPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications."docker-registry"')
  export dockerRegistryDomain="$(cat ${autoSetupHome}/${defaultDockerRegistryPath}/metadata.json | jq -r '.name').${baseDomain}"
  export dockerRegistryUrl="https://${dockerRegistryDomain}"
  ## S3 Objhect Store
  export defaultS3ObjectStorePath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications."s3-object-store"')
  export s3ObjectStoreDomain="$(cat ${autoSetupHome}/${defaultS3ObjectStorePath}/metadata.json | jq -r '.name').${baseDomain}"
  export s3ObjectStoreUrl="https://${s3ObjectStoreDomain}"

}
