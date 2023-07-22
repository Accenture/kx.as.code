dockerCoreRegistryGetImageShaDigest() { 

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local imagePath=${1}
  local imageTag=${2}
  local dockerRegistryPassword=$(getPassword "docker-registry-${baseUser}-password" "docker-registry")

  # Get image sha for tag
  curl -s -S -I -u ${baseUser}:${dockerRegistryPassword} \
        -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
        https://docker-registry.${baseDomain}/v2/${imagePath}/manifests/${imageTag} | \
        grep "docker-content-digest:" | awk {'print $2'} | tr '\r\n' ' '

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}