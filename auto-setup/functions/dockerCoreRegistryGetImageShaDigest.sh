dockerCoreRegistryGetImageShaDigest() {

  local imagePath=${1}
  local imageTag=${2}
  local dockerRegistryPassword=$(getPassword "docker-registry-${namespace}-password" "docker-registry")

  # Get image sha for tag
  curl -s -S -I -u ${namespace}:${dockerRegistryPassword} \
        -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
        https://docker-registry.${baseDomain}/v2/${imagePath}/manifests/${imageTag} | \
        grep "docker-content-digest:" | awk {'print $2'} | tr '\r\n' ' '

}
