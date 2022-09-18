#!/bin/bash

# Get name of pod
dockerRegistryPod=$(kubectl get pod -n docker-registry -o json | jq -r '.items[] | select(.spec.containers[0].image=="registry:2") | .metadata.name')

# Execute command
kubectl exec -it ${dockerRegistryPod} -n docker-registry -- /bin/registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true
