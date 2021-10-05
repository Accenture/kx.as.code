#!/bin/bash -x
set -euo pipefail

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token")
