stopJProfilerInPod() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    local podName=${1:-}
    local podNamespace=${2:-default}

    # Stop JProfiler
    log_debug ""
    kubectl exec ${podName} -n ${podNamespace} -- bash -c ''

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}