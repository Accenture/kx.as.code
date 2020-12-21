#!/bin/bash -eux

# Delete diretories
rm -rf $HOME/KX_Data/Confluence

# Delete Confluence deployments for K8s
kubectl delete -f .

# Delete desktop shortcut
rm -f $HOME/Desktop/Confluence.desktop
