#!/bin/bash -x
set -euo pipefail

# Enable DNS resolution in Kubernetes for *.${baseDomain} domain
echo '''
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
            max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
    '${baseDomain}':53 {
        errors
        cache 30
        forward . '${mainIpAddress}'
    }
''' | kubectl apply -f -
