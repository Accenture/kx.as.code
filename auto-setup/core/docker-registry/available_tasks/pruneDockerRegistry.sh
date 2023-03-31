#!/bin/bash

# Execute command
kubectl exec $(kubectl get pod -n docker-registry -o name) -c docker-registry -n docker-registry -- bin/registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true

# Clean up local file system as well
docker system prune --force