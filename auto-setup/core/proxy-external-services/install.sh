#!/bin/bash

# Apply ingress resources to proxy access via NGINX ingress controller
kubectl create namespace external-endpoints || log_info "Namespace \"external-endpoints\" already exists"

for ingressParameters in ${ingressToProxy}
do

serviceName=$(echo ${ingressParameters} | cut -d':' -f1)
servicePort=$(echo ${ingressParameters} | cut -d':' -f2)
dedicatedExternalOauthIngressDomain=$(echo ${ingressParameters} | cut -d':' -f3)

# Add Kubernetes service resource
echo """apiVersion: v1
kind: Service
metadata:
  name: proxy-service-${serviceName}
  namespace: external-endpoints
spec:
  type: ExternalName
  externalName: ${serviceName}.${baseDomain}
""" | /usr/bin/sudo tee ${installationWorkspace}/external-${serviceName}-service.yaml
kubectl apply -f ${installationWorkspace}/external-${serviceName}-service.yaml

# Add Kubernetes ingress resource
echo """apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: proxy-service-${serviceName}-ingress
  namespace: external-endpoints
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/upstream-vhost: ${serviceName}.${baseDomain}
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${serviceName}.${baseDomain}
  rules:
  - host: ${serviceName}.${baseDomain}
    http:
      paths:
      - backend:
          service:
            name: proxy-service-${serviceName}
            port:
              number: ${servicePort}
        path: /
        pathType: ImplementationSpecific
""" | /usr/bin/sudo tee ${installationWorkspace}/external-${serviceName}-ingress.yaml
kubectl apply -f ${installationWorkspace}/external-${serviceName}-ingress.yaml

# Add external ingress with OAUTH authentication
log_debug "FUNCTION_CALL: addOauthProxyToComponentNamespace \"proxy-service-${serviceName}-ingress\" \"external-endpoints\" \"${serviceName}\""
addOauthProxyToComponentNamespace "proxy-service-${serviceName}-ingress" "external-endpoints" "${serviceName}" "${dedicatedExternalOauthIngressDomain}"

done
