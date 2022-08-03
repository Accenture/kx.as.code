#!/bin/bash
set -euo pipefail

# Create postgresql password or use existing if it already exists
postgresqlPasswordExists=$(kubectl get secret --namespace ${namespace} sonarqube-postgresql -o json | jq -r '.data."postgresql-password"')
if [[ -n ${postgresqlPasswordExists}   ]]; then
    export postgresqlPassword=$(echo ${postgresqlPasswordExists} | base64 --decode)
    log_info "SonarQube postgresql password already exists. Using that one"
else
    # Create SonarQube Postgresql password
    export postgresqlPassword=$(managedPassword "sonarqube-postgresql-password" "${componentName}")
    log_info "SonarQube postgresql password does not exist. Creating a new one"
fi
