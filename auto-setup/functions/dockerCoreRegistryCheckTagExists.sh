dockerCoreRegistryCheckTagExists() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local image=${1}

  local imagePath=$(echo ${image} | cut -d':' -f1)
  local imageTag=$(echo ${image} | cut -d':' -f2)

  local dockerRegistryPassword=$(getPassword "docker-registry-${baseUser}-password" "docker-registry")

  # Check if tag exists in core docker registry
  dockerImageTagExists=$(curl -X GET -u ${baseUser}:${dockerRegistryPassword} \
    https://docker-registry.${baseDomain}/v2/${imagePath}/tags/list | \
    jq -r '.tags[] | contains("'${imageTag}'")')

  if [[ ${dockerImageTagExists} ]]; then
    log_debug "Docker image ${imagePath}:${imageTag} was found in the local core registry"
    true
    return
  else
    log_error "Docker image ${imagePath}:${imageTag} was not found in the local core registry"
    exit 1
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}