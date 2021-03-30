#!/bin/bash -x

kubectl get secret elastic-credentials --namespace ${namespace} || \
kubectl create secret generic elastic-credentials \
      --from-literal=ELASTIC_USERNAME=${vmUser} \
      --from-literal=ELASTIC_PASSWORD=${vmPassword} \
      --namespace ${namespace}
