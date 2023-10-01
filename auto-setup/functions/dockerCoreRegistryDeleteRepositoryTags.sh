dockerCoreRegistryDeleteRepositoryTags() { 

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local imagePath=${1}
  local dockerRegistryPassword=$(getPassword "docker-registry-${baseUser}-password" "docker-registry")

  # Get repository tags
  local imageTags=$(dockerCoreRegistryGetImageTags "${imagePath}")

  # Delete image tags from registry
  for imageTag in ${imageTags}
  do
    # Get image tag sha
    local imageTagSha=$(dockerCoreRegistryGetImageShaDigest "${imagePath}" "${imageTag}")

    # Delete image with sha reference
    curl -u ${baseUser}:${dockerRegistryPassword} \
     -X DELETE https://docker-registry.${baseDomain}/v2/${imagePath}/manifests/${imageTagSha}
  done

  # Prune Docker Registry
  kubectl exec $(kubectl get pod -n docker-registry -o name) -c docker-registry -n docker-registry -- bin/registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true

  # Clean up local file system as well
  docker system prune --force

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}