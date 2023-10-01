dockerCoreRegistryGetImageTags() { 

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local imagePath=${1}

  # Get image tags
  curl -sS -X GET -u ${baseUser}:${dockerRegistryPassword} \
    https://docker-registry.${baseDomain}/v2/${imagePath}/tags/list | jq -r '.tags[]' | tr '\r\n' ' '

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}