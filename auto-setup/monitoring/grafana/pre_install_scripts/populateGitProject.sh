#!/bin/bash -x
set -euo pipefail

populateGitlabProject "devops" "grafana-image-renderer" "${autoSetupHome}/monitoring/grafana/deployment_yaml"
