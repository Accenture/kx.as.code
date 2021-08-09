#!/bin/bash -eux

echo '''
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: harbor-harbor-ingress
    namespace: harbor
    annotations:
        ingress.kubernetes.io/proxy-body-size: "0"
        ingress.kubernetes.io/ssl-redirect: "true"
        meta.helm.sh/release-name: harbor
        meta.helm.sh/release-namespace: harbor
        nginx.ingress.kubernetes.io/proxy-body-size: 10000m
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
    labels:
      app: harbor
      app.kubernetes.io/managed-by: Helm
      chart: harbor
      heritage: Helm
      release: harbor
spec:
    rules:
    - host: '${componentName}'.'${baseDomain}'
      http:
        paths:
        - backend:
            service:
              name: harbor-harbor-portal
              port:
                number: 80
          path: /
          pathType: ImplementationSpecific
        - backend:
            service:
              name: harbor-harbor-core
              port:
                number: 80
          path: /api/
          pathType: ImplementationSpecific
        - backend:
            service:
              name: harbor-harbor-core
              port:
                number: 80
          path: /service/
          pathType: ImplementationSpecific
        - backend:
            service:
              name: harbor-harbor-core
              port:
                number: 80
          path: /v2/
          pathType: ImplementationSpecific
        - backend:
            service:
              name: harbor-harbor-core
              port:
                number: 80
          path: /chartrepo
          pathType: ImplementationSpecific
        - backend:
            service:
              name: harbor-harbor-core
              port:
                number: 80
          path: /c/
          pathType: ImplementationSpecific
    tls:
    - hosts:
      - '${componentName}'.'${baseDomain}'
      secretName: kx.as.code-wildcard-cert
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: harbor-harbor-ingress-notary
    namespace: harbor
    annotations:
      ingress.kubernetes.io/proxy-body-size: "0"
      ingress.kubernetes.io/ssl-redirect: "true"
      meta.helm.sh/release-name: harbor
      meta.helm.sh/release-namespace: harbor
      nginx.ingress.kubernetes.io/proxy-body-size: 10000m
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    labels:
      app: harbor
      app.kubernetes.io/managed-by: Helm
      chart: harbor
      heritage: Helm
      release: harbor
spec:
    rules:
    - host: notary.'${baseDomain}'
      http:
        paths:
        - backend:
            service:
              name: harbor-harbor-notary-server
              port:
                number: 4443
          path: /
          pathType: ImplementationSpecific
    tls:
    - hosts:
      - notary.'${baseDomain}'
      secretName: kx.as.code-wildcard-cert
---
''' | sudo tee ${installationWorkspace}/${componentName}_ingress.yaml

sudo kubectl -n ${namespace} apply -f ${installationWorkspace}/${componentName}_ingress.yaml
