loginToCoreRegistry() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Get password
  export defaultRegistryUserPassword=$(managedApiKey "docker-registry-${baseUser}-password" "docker-registry")
  echo ${defaultRegistryUserPassword} | docker login -u ${baseUser} https://docker-registry.${baseDomain} --password-stdin

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
