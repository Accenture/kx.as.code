#!/bin/bash

# Remove docker config from configmap. Work around as helm chart ignores this in values.yaml
#kubectl get configmap influxdata-telegraf-ds -n ${namespace} --show-managed-fields=false --show-labels=false -o yaml | sed '/docker/d' | kubectl apply -n ${namespace} -f -

# Apply INFLUX_TOKEN env variable to daemonset, as not configurable via helm
kubectl set env daemonset influxdata-telegraf-ds INFLUX_TOKEN="${influxdb2AdminToken}" -n ${namespace}
