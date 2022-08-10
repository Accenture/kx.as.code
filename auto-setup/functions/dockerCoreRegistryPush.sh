pushDockerImageToCoreRegistry() {
  
  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  imagePathToPush=$1

  # Login
  loginToCoreRegistry

  # Push image to core registry
  docker push docker-registry.${baseDomain}/${imagePathToPush}

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
