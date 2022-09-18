#!/bin/bash

# Create secret
mssqlServerPassword="$(managedPassword "mssql-server-sa-password" "mssql-server")"
kubectl create secret generic mssql-server --from-literal=SA_PASSWORD="${mssqlServerPassword}" --namespace=${namespace}