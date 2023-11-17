#!/bin/bash

# Completey clear docker registry. This maybe needed if Kubernetes is unable to pull images due to an EOF error
kubectl exec $(kubectl get pod -l app=docker-registry -n docker-registry -o name) -c docker-registry -n docker-registry -- \
    sh -c 'rm -rf /var/lib/registry/docker/registry/v2/*'

# Restart the pod
kubectl delete $(kubectl get pod -l app=docker-registry -n docker-registry -o name) -n docker-registry