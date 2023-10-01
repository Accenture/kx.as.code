#!/bin/bash

# Wait until API is available before continuing
checkUrlHealth "https://${componentName}.${baseDomain}/api/v2.0/projects" "200"

# Get Harbor Project Ids
export kxHarborProjectId=$(harborGetProjectId "kx-as-code")
export devopsHarborProjectId=$(harborGetProjectId "devops")



