#!/bin/bash -x
set -euo pipefail

# Delete ArgoCD deployments for K8s
kubectl delete -n argocd \
    -f argocd-install.yaml \
    -f argocd-ingress.yaml
