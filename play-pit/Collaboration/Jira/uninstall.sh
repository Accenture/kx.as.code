#!/bin/bash -eux

# Delete diretories
rm -rf $HOME/KX_Data/Jira

# Delete jira deployments for K8s
kubectl delete -f .

# Delete desktop shortcut
rm -f $HOME/Desktop/Jira.desktop
