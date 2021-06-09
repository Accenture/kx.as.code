#!/bin/bash -x
set -euo pipefail

# Install Kubernetes Dashboard
curl https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml --output ${installationWorkspace}/dashboard.yaml
kubectl apply -f ${installationWorkspace}/dashboard.yaml -n ${namespace}

# Create Service Token for Accessing Dashboard
serviceAccountExists=$(kubectl get serviceaccount dashboard -o json | jq -r '.metadata.name')
if [[ -z ${serviceAccountExists} ]]; then
    kubectl create serviceaccount dashboard -n default
fi

# Create Cluster Role Binding
clusterRoleBindingExists=$(kubectl get clusterrolebinding dashboard-admin -o json | jq -r '.metadata.name')
if [[ -z ${clusterRoleBindingExists} ]]; then
    kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
fi

# Create Secret for Kubernetes Dashboard Certificates
kubectl delete secret kubernetes-dashboard-certs -n ${namespace}
kubectl create secret generic kubernetes-dashboard-certs --from-file=${installationWorkspace}/kx-certs -n ${namespace}

# Update Kubernetes Dashboard with new certificate
disableSessionTimeout=$(cat ${installationWorkspace}/profile-config.json | jq -r '.config.disableSessionTimeout')
if [[ ${disableSessionTimeout} == "true"   ]]; then
    sed -i '/^ *args:/,/^ *[^:]*:/s/^.*- --auto-generate-certificates/            - --tls-cert-file=\/tls.crt\n            - --tls-key-file=\/tls.key\n            - --token-ttl=0\n            #- --auto-generate-certificates/' ${installationWorkspace}/dashboard.yaml
else
    sed -i '/^ *args:/,/^ *[^:]*:/s/^.*- --auto-generate-certificates/            - --tls-cert-file=\/tls.crt\n            - --tls-key-file=\/tls.key\n            #- --auto-generate-certificates/' ${installationWorkspace}/dashboard.yaml
fi
kubectl apply -f ${installationWorkspace}/dashboard.yaml -n ${namespace}

# Make Kubernetes Dashboard Available via Domain Name "k8s-dashboard.kx-as-code.local"
cat << EOF > ${installationWorkspace}/dashboard-ingress.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: kubernetes-dashboard-ingress
  annotations:
     kubernetes.io/ingress.class: "nginx"
     nginx.ingress.kubernetes.io/ssl-passthrough: "true"
     nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - ${componentName}.${baseDomain}
  rules:
  - host: ${componentName}.${baseDomain}
    http:
      paths:
       - path: /
         backend:
           serviceName: kubernetes-dashboard
           servicePort: 443
EOF
kubectl apply -f ${installationWorkspace}/dashboard-ingress.yaml -n ${namespace}
