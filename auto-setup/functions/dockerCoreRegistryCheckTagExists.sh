dockerCoreRegistryCheckTagExists() {

  local image=${1}
  local imagePath=$(echo ${image} | cut -d':' -f1)
  local imageTag=$(echo ${image} | cut -d':' -f2)
  local dockerRegistryPassword=$(getPassword "docker-registry-${namespace}-password" "docker-registry")

  # Check if tag exists in core docker registry
  dockerImageTagExists=$(curl -X GET -u ${namespace}:${dockerRegistryPassword} \
    https://docker-registry.${baseDomain}/v2/${imagePath}/tags/list | \
    jq -r '.tags[] | contains("'${imageTag}'")' | grep "true" | head -1)

  if [[ ${dockerImageTagExists} ]]; then
    log_debug "Docker image ${imagePath}:${imageTag} was found in the local core registry"
    true
    return
  else
    log_error "Docker image ${imagePath}:${imageTag} was not found in the local core registry"
    exit 1
  fi

}
