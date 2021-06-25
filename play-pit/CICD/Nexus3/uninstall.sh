#!/bin/bash -x
set -euo pipefail

# Delete diretories
rm -rf $HOME/KX_Data/Nexus

# Delete Nexus deployment for K8s
kubectl delete -f .

# Delete desktop shortcut
rm -f $HOME/Desktop/Nexus.desktop
