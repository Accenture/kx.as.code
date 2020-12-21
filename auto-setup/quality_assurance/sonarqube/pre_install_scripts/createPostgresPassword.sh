#!/bin/bash -eux

# Create postgresql password or use existing if it already exists
postgresqlPasswordExists=$(kubectl get secret --namespace ${namespace} sonarqube-postgresql -o json | jq -r '.data."postgresql-password"')
if [[ ! -z ${postgresqlPasswordExists} ]]; then
    export postgresqlPassword=$(echo ${postgresqlPasswordExists} | base64 --decode)
    log_info "SonarQube postgresql password already exists. Using that one"
else
    export postgresqlPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
    log_info "SonarQube postgresql password does not exist. Creating a new one"
fi
