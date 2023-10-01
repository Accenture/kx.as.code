dockerCoreRegistryDeleteRepositoryTags() {

  local imagePath=${1:-}
  local dockerRegistryPassword=$(getPassword "docker-registry-${namespace}-password" "docker-registry")

  if [[ -n ${imagePath} ]]; then

    # Get repository tags
    local imageTags=$(dockerCoreRegistryGetImageTags "${imagePath}")

    # Delete image tags from registry
    for imageTag in ${imageTags}
    do
      # Get image tag sha
      local imageTagSha=$(dockerCoreRegistryGetImageShaDigest "${imagePath}" "${imageTag}")

      if [[ -n ${imageTagSha} ]]; then
        # Delete image with sha reference
        curl -u ${namespace}:${dockerRegistryPassword} \
        -X DELETE https://docker-registry.${baseDomain}/v2/${imagePath}/manifests/${imageTagSha}
      fi

    done

    if [[ -n ${imageTags} ]]; then
      # Prune Docker Registry
      kubectl exec $(kubectl get pod -n docker-registry -o name) -c docker-registry -n docker-registry -- bin/registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true || log_warn "Nothing to prune as no \"${imagePath}\" images published into docker registry - \"https://docker-registry.${baseDomain}\""
    fi

    # Clean up local file system as well
    docker system prune --force

  fi

}
