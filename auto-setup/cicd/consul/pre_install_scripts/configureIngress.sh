#!/bin/bash -x
set -euo pipefail

echo """
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ${componentName}
  namespace: ${namespace}
  annotations:
    kubernetes.io/ingress.class: \"nginx\"
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
           serviceName: consul-consul-ui
           servicePort: 80
""" | kubectl apply -n ${namespace} -f -
