loginToCoreRegistry() {
  # Get password
  export defaultRegistryUserPassword=$(managedApiKey "docker-registry-${baseUser}-password" "docker-registry")
  echo ${defaultRegistryUserPassword} | docker login -u ${baseUser} https://docker-registry.${baseDomain} --password-stdin
}
