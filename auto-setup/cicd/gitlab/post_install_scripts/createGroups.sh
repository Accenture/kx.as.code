#!/bin/bash
set -euo pipefail

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")

# Create Groups in Gitlab
gitlabCreateGroup "kx.as.code"
gitlabCreateGroup "devops"
