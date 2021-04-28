#!/bin/bash -eux

# Update Wildcard DNS entry for kx-as-code.local
export nginxIngressControllerIp=$(kubectl get svc ${namespace}-ingress-nginx-controller -n ${namespace} -o jsonpath={.spec.clusterIP})
# Switched from NGINX LB IP to Host IP due to Host Networking enabled for AWS solution
# Will revisit this in future if we add additional main nodes
echo "address=/.${baseDomain}/${mainIpAddress}" | tee -a /etc/dnsmasq.d/${baseDomain}.conf
systemctl restart dnsmasq
