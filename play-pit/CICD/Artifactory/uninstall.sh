#!/bin/bash -eux

# Delete diretories
rm -rf $HOME/KX_Data/Artifactory

# Delete Artifactory  deployments for K8s
kubectl delete -f .

# Delete desktop shortcut
rm -f $HOME/Desktop/Artifactory.desktop
