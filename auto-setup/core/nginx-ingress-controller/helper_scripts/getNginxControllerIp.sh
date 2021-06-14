#!/bin/bash -x
set -euo pipefail

export nginxIngressControllerIp=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n nginx-ingress-controller -o jsonpath={.spec.clusterIP})
