#!/bin/bash -x
set -euo pipefail

# Get NGINX Ingress Controller IP
export nginxIngressIp=$(kubectl get svc nginx-ingress-controller-ingress-nginx-controller -n nginx-ingress-controller -o jsonpath={.spec.clusterIP})
