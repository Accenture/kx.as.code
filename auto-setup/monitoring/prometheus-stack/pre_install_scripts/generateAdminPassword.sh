#!/bin/bash

# Create Grafana Admin Password
export grafanaAdminPassword=$(managedPassword "grafana-admin-password" "grafana")
