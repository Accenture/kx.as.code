#!/bin/bash -x

# Install Elastic Heartbeat
kubectl apply -f ${installComponentDirectory}/deployment_yaml/install.yaml -n ${namespace}