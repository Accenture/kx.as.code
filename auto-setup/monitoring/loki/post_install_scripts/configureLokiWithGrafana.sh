#!/bin/bash
set -euo pipefail

## This scrips creates a loki Datasource in grafana and an integration between grafana and the loki such that the logs can be viewed in the grafana explore section.
curl -X  POST -H "Accept: application/json" -H "Content-Type: application/json" https://${grafanaUser}:${grafanaPassword}@grafana.${baseDomain}/api/datasources --data-binary @- << EOF
{
  "orgId":1,
  "name":"Loki",
  "type":"loki",
  "typeName":"Loki",
  "typeName":"Loki",
  "typeLogoUrl":"public/app/plugins/datasource/loki/img/loki_icon.svg",
  "typeName":"Loki",
  "access":"proxy",
  "url":"http://loki.${namespace}:3100",
  "password":"",
  "user":"",
  "database":"",
  "basicAuth":false,
  "isDefault":false,
  "jsonData":{
  },
  "readOnly":false
}
EOF

# Get Grafana Admin Password
export grafanaAdminPassword=$(managedPassword "grafana-admin-password" "grafana")

# Get UID of created datasource to use when importing Loki dashboard
export lokiGrafanaDataSourceUid=$(curl -u admin:"${grafanaAdminPassword}" https://grafana.${baseDomain}/api/datasources/name/Loki | jq -r '.uid')