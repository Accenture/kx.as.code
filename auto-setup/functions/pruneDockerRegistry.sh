pruneDockerRegistry() {

    # Execute command
    #kubectl exec $(kubectl get pod -l app=docker-registry -n docker-registry -o name) -c docker-registry -n docker-registry -- bin/registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true

    kubectl exec $(kubectl get pod -l app=docker-registry -n docker-registry -o name) -c docker-registry -n docker-registry -- \
         sh -c 'if ls /docker/registry/v2/repositories; then \
                  bin/registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true; \
                else \
                  echo "No repositories created yet. Nothing to purge"; \
                fi'

}
