#!/bin/bash -eux

# Delete KX-AS.CODE Docs deployment from Kubernetes
kubectl delete \
  -f deployment.yaml \
  -f ingress.yaml \
  -f service.yaml \
  -n devops

rm -f /home/${vmUser}/Desktop'/KX.AS.CODE Docs'