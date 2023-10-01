#!/bin/bash

# Workaround to avoid the error Error: UPGRADE FAILED: cannot patch "gitlab-webservice" with kind Ingress:
# admission webhook "validate.nginx.ingress.kubernetes.io" denied the request: rejecting admission review
# because the request does not contains an Ingress resource but networking.k8s.io/v1, Resource=ingresses with name
# gitlab-webservice in namespace gitlab
validatingWebhookExists=$(kubectl get ValidatingWebhookConfiguration nginx-ingress-controller-ingress-nginx-admission -o json | jq -r '.metadata.name')
if [[ ${validatingWebhookExists} ]]; then
    kubectl delete ValidatingWebhookConfiguration nginx-ingress-controller-ingress-nginx-admission
fi
