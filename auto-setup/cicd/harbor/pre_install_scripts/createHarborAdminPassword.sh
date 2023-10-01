#!/bin/bash

# Create Create Harbor Admin Password
export harborAdminPassword=$(managedApiKey "harbor-admin-password" "harbor")
