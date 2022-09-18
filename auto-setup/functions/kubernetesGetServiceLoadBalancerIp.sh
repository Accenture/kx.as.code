kubernetesGetServiceLoadBalancerIp() {

    serviceName=${1}
    namespace=${2-${namespace}} # use component's defined namespace if not passed in function call

    kubectl get service -n ${namespace} ${serviceName} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    
}