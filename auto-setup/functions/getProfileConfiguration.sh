getProfileConfiguration() {

  # Get configs from profile-config.json
  export virtualizationType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.virtualizationType')
  export baseIpType=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpType')
  export dnsResolution=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.dnsResolution')

  if [[ ${baseIpType} == "static"   ]]; then
      # Get fixed IPs if defined
      export fixedIpHosts=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses | keys[]')
      for fixIpHost in ${fixedIpHosts}; do
          fixIpHostVariableName=$(echo ${fixIpHost} | sed 's/-/__/g')
          export ${fixIpHostVariableName}_IpAddress="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
          if [[ ${fixIpHost} == "kx-main1" ]]; then
              export mainIpAddress="$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.baseFixedIpAddresses."'${fixIpHost}'"')"
          fi
      done
      export fixedNicConfigGateway=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.gateway')
      export fixedNicConfigDns1=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.dns1')
      export fixedNicConfigDns2=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.staticNetworkSetup.dns2')
  else
      export mainIpAddress=$(ip a s ${netDevice} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
  fi

  export environmentPrefix=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.environmentPrefix')

  if [ -z ${environmentPrefix} ]; then
      export baseDomain=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseDomain')
  else
      export baseDomain="${environmentPrefix}.$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseDomain')"
  fi

  export numKxMainNodes=$(cat ${installationWorkspace}/profile-config.json | jq -r '.vm_properties.main_node_count')
  if [[ "${numKxMainNodes}" = "null" ]]; then
      export numKxMainNodes="1"
  fi

  export defaultKeyboardLanguage=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.defaultKeyboardLanguage')
  export baseUser=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseUser')
  export basePassword=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.basePassword')
  export baseIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeStart')
  export baseIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.baseIpRangeEnd')
  export metalLbIpRangeStart=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.metalLbIpRange.ipRangeStart')
  export metalLbIpRangeEnd=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.metalLbIpRange.ipRangeEnd')
  export sslProvider=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.sslProvider')
  export sslDomainAdminEmail=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.sslDomainAdminEmail')
  export letsEncryptEnvironment=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.letsEncryptEnvironment')
  # Get proxy settings
  export httpProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.http_proxy')
  export httpsProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.https_proxy')
  export noProxySetting=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.proxy_settings.no_proxy')

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

}