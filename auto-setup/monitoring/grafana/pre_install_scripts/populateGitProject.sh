#!/bin/bash -x
set -euo pipefail

populateGitlabProject "devops" "grafana-image-renderer" "${autoSetupHome}/monitoring/grafana-image-renderer/deployment_yaml"
