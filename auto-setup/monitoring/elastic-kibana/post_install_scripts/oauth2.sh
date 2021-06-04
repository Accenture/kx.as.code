#!/bin/bash -x
set -euo pipefail

# Deploy oauth-proxy
echo '''
kind: Service
apiVersion: v1
metadata:
  name: oauth2-proxy
spec:
  type: ExternalName
  externalName: oauth2-proxy.kubernetes-dashboard.svc.cluster.local
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: '${componentName}'-oauth2-ingress
  namespace: elastic-stack
spec:
  tls:
  - hosts:
    - {{componentName}}.{{baseDomain}}
  rules:
  - host: {{componentName}}.{{baseDomain}}
    http:
      paths:
      - path: /oauth2
        backend:
          serviceName: oauth2-proxy
          servicePort: 4180
''' | sudo tee ${installationWorkspace}/kibana-oauth2-ingress.yaml
sudo kubectl apply -f ${installationWorkspace}/kibana-oauth2-ingress.yaml
