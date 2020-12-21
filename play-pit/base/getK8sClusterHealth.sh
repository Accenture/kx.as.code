#!/bin/bash -eux

# Output K8s cluster health
kubectl cluster-info
kubectl get cs
