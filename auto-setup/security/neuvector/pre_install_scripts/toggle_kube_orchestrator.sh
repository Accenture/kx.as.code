#!/bin/bash

# Set variables for later function "autoSetupHelmInstall()" which will replace the {{ mustache }} variables in values_template.yaml via the envhandlebars utility

if [[ "${kubeOrchestrator}" == "k8s" ]]; then
    log_debug "Set Kube toggle to K8s for NeuVector helm values file"
    export K3S_TOGGLE=false
    export K8S_TOGGLE=true
else
    log_debug "Set Kube toggle to K3s for NeuVector helm values file"
    export K3S_TOGGLE=true
    export K8S_TOGGLE=false
fi