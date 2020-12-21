#!/bin/bash -eux

# Update Wildcard DNS entry for kx-as-code.local
export nginxIngressControllerIp=$(kubectl get svc ${namespace}-ingress-nginx-controller -n ${namespace} -o jsonpath={.spec.clusterIP})
echo "address=/.${baseDomain}/${nginxIngressControllerIp}" | tee -a /etc/dnsmasq.d/${baseDomain}.conf
systemctl restart dnsmasq
