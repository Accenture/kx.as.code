#!/bin/bash -x

# Copy Elastic Stack credentials & certificates from elastic-stack namespace to kube-system namespace
kubectl get secret elastic-credentials --namespace=elastic-stack -o yaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=kube-system -f -
kubectl get secret elastic-certificates --namespace=elastic-stack -o yaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=kube-system -f -
