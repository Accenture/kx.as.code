#!/bin/bash -eux

# Create KX.AS.CODE "Docs" project in Gitlab
export kxDocsProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_docs") | .id')
if [[ -z ${kxDocsProjectId} ]]; then
  for i in {1..5}
  do
    curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=KX.AS.CODE Documentation Engine' \
      --data 'name=kx.as.code_docs' \
      --data 'namespace_id='${kxascodeGroupId}'' \
      --data 'path=kx.as.code_docs' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects
      export kxDocsProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_docs") | .id')
      if [[ ! -z "${kxDocsProjectId}" ]]; then break; else log_warn "KX.AS.CODE_DOCS Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "KX.AS.CODE \"Docs\" Project already exists in Gitlab. Skipping creation"
fi

# Create KX.AS.CODE "TechRadar" project in Gitlab
export techRadarProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_techradar") | .id')
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
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects
      export techRadarProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="kx.as.code_techradar") | .id')
      if [[ ! -z ${techRadarProjectId} ]]; then break; else log_warn "KX.AS.CODE_TECHRADAR Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "KX.AS.CODE \"TechRadar\" Project already exists in Gitlab. Skipping creation"
fi

# Create KX.AS.CODE "TechRadar" project in Gitlab
export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="kx.as.code") | .id')
if [[ -z ${kxascodeProjectId} ]]; then
  for i in {1..5}
  do
    curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=KX.AS.CODE Source Code' \
      --data 'name=kx.as.code' \
      --data 'namespace_id='${kxascodeGroupId}'' \
      --data 'path=kx.as.code' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects
      export kxascodeProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="kx.as.code") | .id')
      if [[ ! -z ${kxascodeProjectId} ]]; then break; else log_warn "KX.AS.CODE Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "KX.AS.CODE Project already exists in Gitlab. Skipping creation"
fi

# Create Grafana Image Renderer project in Gitlab
export grafanaImageRendererProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="grafana_image_renderer") | .id')
if [[ -z ${grafanaImageRendererProjectId} ]]; then
  for i in {1..5}
  do
    curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Grafana image renderer Kubernetes deployment files' \
      --data 'name=grafana_image_renderer' \
      --data 'namespace_id='$devopsGroupId'' \
      --data 'path=grafana_image_renderer' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects
      export grafanaImageRendererProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="grafana_image_renderer") | .id')
      if [[ ! -z ${grafanaImageRendererProjectId} ]]; then break; else log_warn "grafana_image_renderer Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Grafana Image Renderer Project already exists in Gitlab. Skipping creation"
fi

# Create Nexus3 project in Gitlab
export nexus3ProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="nexus3") | .id')
if [[ -z ${nexus3ProjectId} ]]; then
  for i in {1..5}
  do
    curl -s -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Nexus3 Kubernetes deployment files' \
      --data 'name=nexus3' \
      --data 'namespace_id='$devopsGroupId'' \
      --data 'path=nexus3' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects
      export nexus3ProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="nexus3") | .id')
      if [[ ! -z ${nexus3ProjectId} ]]; then break; else log_warn "Nexus3 Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Nexus3 Project already exists in Gitlab. Skipping creation"
fi

# Create Jira project in Gitlab
export jiraProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="jira") | .id')
if [[ -z ${jiraProjectId} ]]; then
  for i in {1..5}
  do
    curl -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Jira Kubernetes deployment files' \
      --data 'name=jira' \
      --data 'namespace_id='${devopsGroupId}'' \
      --data 'path=jira' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects | jq '.id'
      export jiraProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="jira") | .id')
      if [[ ! -z ${jiraProjectId} ]]; then break; else log_warn "Jira Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Jira Project already exists in Gitlab. Skipping creation"
fi

# Create Confluence project in Gitlab
export confluenceProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="confluence") | .id')
if [[ -z ${confluenceProjectId} ]]; then
  for i in {1..5}
  do
    curl -XPOST --header "Private-Token: ${personalAccessToken}" \
      --data 'description=Confluence Kubernetes deployment files' \
      --data 'name=confluence' \
      --data 'namespace_id='${devopsGroupId}'' \
      --data 'path=confluence' \
      --data 'default_branch=master' \
      --data 'visibility=private' \
      --data 'container_registry_enabled=false' \
      --data 'auto_devops_enabled=false' \
      https://gitlab.${baseDomain}/api/v4/projects | jq '.id'
      export confluenceProjectId=$(curl -s --header "Private-Token: ${personalAccessToken}" https://gitlab.${baseDomain}/api/v4/projects | jq '.[] | select(.name=="confluence") | .id')
      if [[ ! -z ${confluenceProjectId} ]]; then break; else log_warn "Confluence Gitlab project not created. Trying again ($i of 5)"; sleep 5; fi
  done
else
    log_info "Confluence Project already exists in Gitlab. Skipping creation"
fi