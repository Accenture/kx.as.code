getProfileConfiguration() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Get configs from profile-config.json
  export virtualizationType=$(cat ${profileConfigJsonPath} | jq -r '.config.virtualizationType')
  export standaloneMode=$(cat ${profileConfigJsonPath} | jq -r '.config.standaloneMode')
  export baseIpType=$(cat ${profileConfigJsonPath} | jq -r '.config.baseIpType')
  export dnsResolution=$(cat ${profileConfigJsonPath} | jq -r '.config.dnsResolution')
  export kubeOrchestrator=$(cat ${profileConfigJsonPath} | jq -r '.config.kubeOrchestrator')
  export updateSourceOnStart=$(cat ${profileConfigJsonPath} | jq -r '.config.updateSourceOnStart')
  
  if [[ ${baseIpType} == "static"   ]]; then
      # Get fixed IPs if defined
      export fixedIpHosts=$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses | keys[]')
      for fixIpHost in ${fixedIpHosts}; do
          fixIpHostVariableName=$(echo ${fixIpHost} | sed 's/-/__/g')
          export ${fixIpHostVariableName}_IpAddress="$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
          if [[ ${fixIpHost} == "kx-main1" ]]; then
              export mainIpAddress="$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
          fi
      done
      export fixedNicConfigGateway=$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.gateway')
      export fixedNicConfigDns1=$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.dns1')
      export fixedNicConfigDns2=$(cat ${profileConfigJsonPath} | jq -r '.config.staticNetworkSetup.dns2')
  else
      export mainIpAddress=$(ip a s ${netDevice} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
  fi

  export environmentPrefix=$(cat ${profileConfigJsonPath} | jq -r '.config.environmentPrefix')
  if [ -z ${environmentPrefix} ]; then
      export baseDomain=$(cat ${profileConfigJsonPath} | jq -r '.config.baseDomain')
  else
      if [[ "${environmentPrefix}" == "ownerId" ]]; then
          export ownerId=$(getOwnerId)
          export environmentPrefix=${ownerId}
          export baseDomain="${ownerId}.$(cat ${profileConfigJsonPath} | jq -r '.config.baseDomain')"
        else
          export baseDomain="${environmentPrefix}.$(cat ${profileConfigJsonPath} | jq -r '.config.baseDomain')"
        fi
  fi

  # For use in tools that require and organization name, where "." cause an error
  export baseDomainWithHyphens=$(echo ${baseDomain} | sed 's/\./-/g')

  export numKxMainNodes=$(cat ${profileConfigJsonPath} | jq -r '.vm_properties.main_node_count')
  if [[ "${numKxMainNodes}" = "null" ]]; then
      export numKxMainNodes="1"
  fi

  export defaultKeyboardLanguage=$(cat ${profileConfigJsonPath} | jq -r '.config.defaultKeyboardLanguage')
  export baseUser=$(getOwnerId)
  export basePassword=$(cat ${profileConfigJsonPath} | jq -r '.config.basePassword')
  export baseIpRangeStart=$(cat ${profileConfigJsonPath} | jq -r '.config.baseIpRangeStart')
  export baseIpRangeEnd=$(cat ${profileConfigJsonPath} | jq -r '.config.baseIpRangeEnd')
  export logLevel=$(cat ${profileConfigJsonPath} | jq -r '.config.logLevel')
  export metalLbIpRangeStart=$(cat ${profileConfigJsonPath} | jq -r '.config.metalLbIpRange.ipRangeStart')
  export metalLbIpRangeEnd=$(cat ${profileConfigJsonPath} | jq -r '.config.metalLbIpRange.ipRangeEnd')
  export sslProvider=$(cat ${profileConfigJsonPath} | jq -r '.config.sslProvider')
  export sslDomainAdminEmail=$(cat ${profileConfigJsonPath} | jq -r '.config.sslDomainAdminEmail')
  export letsEncryptEnvironment=$(cat ${profileConfigJsonPath} | jq -r '.config.letsEncryptEnvironment')
  # Get proxy settings
  export httpProxySetting=$(cat ${profileConfigJsonPath} | jq -r '.config.proxy_settings.http_proxy')
  export httpsProxySetting=$(cat ${profileConfigJsonPath} | jq -r '.config.proxy_settings.https_proxy')
  export noProxySetting=$(cat ${profileConfigJsonPath} | jq -r '.config.proxy_settings.no_proxy')

  # Get default applications for certain services
  ## Git
  export defaultGitPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.git')
  export gitDomain="$(cat ${autoSetupHome}/${defaultGitPath}/metadata.json | jq -r '.name' | sed 's/-ce//g').${baseDomain}"
  export gitUrl="https://${gitDomain}"
  ## OAUTH
  export defaultOauthPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.oauth')
  export oauthDomain="$(cat ${autoSetupHome}/${defaultOauthPath}/metadata.json | jq -r '.name').${baseDomain}"
  export oauthUrl="https://${oauthDomain}"
  ## ChatOps
  export defaultChatopsPath=$(cat ${installationWorkspace}/metadata.json | jq -r '.metadata.defaultApplications.chatops')
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

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
