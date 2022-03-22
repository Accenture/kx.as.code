pushDockerImageToCoreRegistry() {
  
  imagePathToPush=$1

  # Login
  loginToCoreRegistry

  # Push image to core registry
  docker push docker-registry.${baseDomain}/${imagePathToPush}
  
}
