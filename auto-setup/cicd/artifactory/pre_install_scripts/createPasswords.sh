#!/bin/bash

# Create Artifactory Admin and Postgresql Passwords
export adminPassword=$(managedPassword "artifactory-admin-password" "artifactory")
export postgresqlPassword=$(managedApiKey "artifactory-postgresql-password" "artifactory")