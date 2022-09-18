dockerCoreRegistryCheckTagExists() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  image=${1}

  imagePath=$(echo ${image} | cut -d':' -f1)
  imageTag=$(echo ${image} | cut -d':' -f2)

  local dockerRegistryPassword=$(getPassword "docker-registry-${baseUser}-password" "docker-registry")

  # Check if tag exists in core docker registry
  dockerImageTegExists=$(curl -X GET -u ${baseUser}:${dockerRegistryPassword} \
    https://docker-registry.${baseDomain}/v2/${imagePath}/tags/list | \
    jq -r '.tags[] | contains("'${imageTag}'")')

  if [[ ${dockerImageTegExists} ]]; then
    log_debug "Docker image ${imagePath}:${imageTag} was found in the local core registry"
    true
    return
  else
    log_error "Docker image ${imagePath}:${imageTag} was not found in the local core registry"
    false
    return
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}