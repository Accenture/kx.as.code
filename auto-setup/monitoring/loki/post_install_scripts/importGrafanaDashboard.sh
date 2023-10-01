#!/bin/bash

# Import Loki dashboard (id 13186 -> https://grafana.com/grafana/dashboards/13186-loki-dashboard/)
grafanaImportDashboardJsonFile "${installComponentDirectory}/configs/grafana-loki-dashboard.json"