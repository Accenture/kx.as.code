loginToCoreRegistry() {
  # Get password
  export defaultRegistryUserPassword=$(managedApiKey "docker-registry-${vmUser}-password")
  echo ${defaultRegistryUserPassword} | docker login -u ${vmUser} https://docker-registry.${baseDomain} --password-stdin
}
