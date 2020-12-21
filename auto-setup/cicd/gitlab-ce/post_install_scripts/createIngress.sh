#!/bin/bash -eux

# Create Ingress for Gitlab
echo '''
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: gitlab-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "1200"
spec:
  tls:
  - hosts:
    - '${componentName}'.'${baseDomain}'
  rules:
  - host: '${componentName}'.'${baseDomain}'
    http:
      paths:
       - path: /
         backend:
           serviceName: '${namespace}'-webservice
           servicePort: 8181     
''' | kubectl apply -n ${namespace} -f -