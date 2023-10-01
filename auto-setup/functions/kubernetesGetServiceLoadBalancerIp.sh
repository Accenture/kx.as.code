kubernetesGetServiceLoadBalancerIp() {

    serviceName=${1}
    namespace=${2-${namespace}} # use component's defined namespace if not passed in function call
    ipType=${3:-"lb-ingress-ip"}   # must be either "cluster-ip" or "lb-ingress-ip"

    if [[ "${ipType}" == "lb-ingress-ip" ]]; then
        local jsonPath='{.status.loadBalancer.ingress[0].ip}'
    else
        local jsonPath="{.spec.clusterIP}"
    fi

    kubectl get service -n ${namespace} ${serviceName} -o jsonpath=''${jsonPath}''
    
}
