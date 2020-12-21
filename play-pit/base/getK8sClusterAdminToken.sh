#!/bin/bash

# Get token for logging onto K8s dasbboard
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
echo -e "\n"
sleep 5
read -p "Press [Enter] key to close the window..."
