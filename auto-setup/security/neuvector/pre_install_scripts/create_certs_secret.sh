#!/bin/bash

# Add KX.AS.CODE CA cert to NeuVector namespace
kubectl get secret kx-certificates --namespace=${namespace} ||
        kubectl create secret generic kx-certificates \
        --from-file=${installationWorkspace}/kx-certs \
        --namespace=${namespace}