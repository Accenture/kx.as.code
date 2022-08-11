getNginxControllerIp() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Get NGINX Ingress Controller IP
    kubectl get svc nginx-ingress-controller-ingress-nginx-controller -n nginx-ingress-controller -o jsonpath={.spec.clusterIP}

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}