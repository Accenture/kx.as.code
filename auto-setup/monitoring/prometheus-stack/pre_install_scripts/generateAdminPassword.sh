#!/bin/bash
set -euo pipefail

# Create Grafana Admin Password
export grafanaAdminPassword=$(managedPassword "grafana-admin-password" "grafana")
