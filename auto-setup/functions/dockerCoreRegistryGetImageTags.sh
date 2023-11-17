dockerCoreRegistryGetImageTags() {

  local imagePath=${1:-}
  local imageTag=${2:-}
  local dockerRegistryPassword=$(getPassword "docker-registry-${namespace}-password" "docker-registry")

  if [[ -n "${imagePath}" ]]; then
  
    # Get image tags
    imageTags=$(curl -sS -X GET -u ${namespace}:${dockerRegistryPassword} \
      https://docker-registry.${baseDomain}/v2/${imagePath}/tags/list)

    # Retrieve Docker images tags if tags array is not "null"
    if [[ "$(echo ${imageTags} | jq '.tags')" != "null" ]] || [[ -z "$(echo ${imageTags} | jq '.tags')" ]]; then
      echo ${imageTags} | jq -r '.tags[]' | tr '\r\n' ' '
    fi

  fi
}