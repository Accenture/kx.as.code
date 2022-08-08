#!/bin/bash
set -euo pipefail

# TODO - make this optional depending on whether Gitlab is installed or not
populateGitlabProject "devops" "grafana-image-renderer" "${autoSetupHome}/monitoring/grafana/deployment_yaml"
