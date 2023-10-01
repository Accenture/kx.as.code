kubernetesScaleApp() {

    local appName=${1:-}
    local replicas=${2:-}

    if [[ -n ${appName} ]] && [[ -n ${replicas} ]]; then

        log_debug "Scaling \"${appName}\" to ${replicas} pods"

        if [[ ${replicas} -gt 0 ]]; then
            waitCondition="condition=ready"
        else
            waitCondition="delete"
        fi

        # Scale number of pods for app's deploymment to n number of replicas
        kubectl scale --replicas=${replicas} deployment -n ${namespace} -l app=${appName}

        # Wait for pods to be deleted or available, depending on # of replicas requested
        kubectl wait --for=${waitCondition} pod -l app=${appName} --timeout=60s -n ${namespace}

    else
        log_debug "Received an invalid request to kubernetesScaleApp() function -> appName=\"${appName}\" and replicas=\"${replicas}\". Exiting."
    fi

}