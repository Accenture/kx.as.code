#!/bin/bash

# Remove basic auth if Docker Registry UI AUTH set to use Keycloak
if [[ "${dockerRegistryUiAuth}" == "keycloak" ]] || [[ "${dockerRegistryUiAuth}" == "keycloak-only" ]]; then
    addOauthProxyToComponentNamespace "docker-registry-ui" "docker-registry" "docker-registry-ui" "true"
    if [[ "${dockerRegistryUiAuth}" == "keycloak-only" ]]; then
        # TODO: test docker-registry-ui still works if below annotations not present. Probably not but leaving the code her for now anyway
        kubectl annotate ingress docker-registry-ui nginx.ingress.kubernetes.io/configuration-snippet- -n ${namespace}
        kubectl annotate ingress docker-registry-ui nginx.ingress.kubernetes.io/cors-allow-credentials- -n ${namespace}
        kubectl annotate ingress docker-registry-ui nginx.ingress.kubernetes.io/cors-allow-methods- -n ${namespace}
        kubectl annotate ingress docker-registry-ui nginx.ingress.kubernetes.io/enable-cors- -n ${namespace}
    fi
fi
