getNginxControllerIp() {

    # Get NGINX Ingress Controller IP
    kubectl get svc nginx-ingress-controller-ingress-nginx-controller -n nginx-ingress-controller -o jsonpath={.spec.clusterIP}

}