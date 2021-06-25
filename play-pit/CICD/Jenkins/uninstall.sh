#!/bin/bash -x
set -euo pipefail

# Delete diretories
rm -rf $HOME/KX_Data/Jenkins

# Delete jenkins deployments for K8s
kubectl delete -f .

# Delete desktop shortcut
rm -f $HOME/Desktop/Jenkins.desktop
