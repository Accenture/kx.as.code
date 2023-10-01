startJProfilerInPod() {

    local podName=${1:-}
    local podNamespace=${2:-default}

    # Start JProfiler
    log_debug "kubectl exec ${podName} -n ${podNamespace} -- bash -c 'nohup /app/jprofiler/bin/jpenable --pid=\$(/app/java/bin/jps | grep \"cq-\" | cut -d\" \" -f1) --port=31757 --noinput --gui &'"
    kubectl exec ${podName} -n ${podNamespace} -- bash -c 'nohup /app/jprofiler/bin/jpenable --pid=$(/app/java/bin/jps | grep "cq-" | cut -d" " -f1) --port=31757 --noinput --gui &'

}
