#!/bin/bash -x
set -euo pipefail

# Delete diretories
rm -rf $HOME/KX_Data/K8s_Selenium

# Delete Selenium  deployments for K8s
kubectl delete -f .

# Delete desktop shortcut
rm -f $HOME/Desktop/Selenium.desktop
