#!/bin/bash -eux

# Delete ArgoCD deployments for K8s
kubectl delete -n argocd  \
  -f argocd-install.yaml \
  -f argocd-ingress.yaml
