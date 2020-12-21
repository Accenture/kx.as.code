#!/bin/bash -eux

# Create KX.AS.CODE "TechRadar" project in Gitlab
export kxascodeGroupId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/groups | jq -r '.[] | select(.name=="kx.as.code") | .id')
export techRadarProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_techradar") | .id')
if [[ -z ${techRadarProjectId} ]]; then
  for i in {1..5}
  do
    curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=KX.AS.CODE Technology Radar' \
      --data 'name=kx.as.code_techradar' \
      --data 'namespace_id='${kxascodeGroupId}'' \
      --data 'path=kx.as.code_techradar' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      ${gitUrl}/api/v4/projects
      export techRadarProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" ${gitUrl}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_techradar") | .id')
      if [[ ! -z ${techRadarProjectId} ]]; then break; else log_warn "KX.AS.CODE_TECHRADAR Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "KX.AS.CODE \"TechRadar\" Project already exists in Gitlab. Skipping creation"
fi
