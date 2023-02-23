#!/bin/bash
set -euo pipefail

# Get Grafana username and password
export grafanaUser="admin"
export grafanaPassword=$(getPassword "grafana-admin-password" "grafana")
