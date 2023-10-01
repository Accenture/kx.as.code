#!/bin/bash

# Create RocketChat admin password for use in Helm Chart
export rocketchatAdminPassword=$(managedApiKey "rocketchat-admin-password" "rocketchat")
