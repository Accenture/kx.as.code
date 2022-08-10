kubernetesHealthCheck() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Ensure Kubernetes is available before proceeding to the next step
    timeout -s TERM 6000 bash -c \
        'while [[ "$(kubectl get --raw=\"/readyz\"" != "ok" ]];\
    do sleep 5;\
    done'

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}