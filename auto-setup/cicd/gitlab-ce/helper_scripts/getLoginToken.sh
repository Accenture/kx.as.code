#!/bin/bash -x
set -euo pipefail

# Create OAUTH application in Gitlab for Grafana
export personalAccessToken=$(cat /usr/share/kx.as.code/.config/.admin.gitlab.pat)
