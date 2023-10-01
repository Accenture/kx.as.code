#!/bin/bash

# Wait until API is available before continuing
checkUrlHealth "https://${componentName}.${baseDomain}/api/v2.0/ping" "200"

# Create public kx-as-code project in Habor via API
harborCreateProject "kx-as-code"

# Create public devops project in Harbor via API
harborCreateProject "devops"

