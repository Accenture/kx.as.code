getNginxControllerIp() {

    local ipTypeToReturn=${1:-cluster}

    # Get NGINX Ingress Controller IP
    if [[ "${ipTypeToReturn}" == "external" ]]; then
        kubectl get svc nginx-ingress-controller-ingress-nginx-controller -n nginx-ingress-controller -o json | jq -r '.status.loadBalancer.ingress[0].ip'
    else
        kubectl get svc nginx-ingress-controller-ingress-nginx-controller -n nginx-ingress-controller -o jsonpath={.spec.clusterIP}
    fi

}