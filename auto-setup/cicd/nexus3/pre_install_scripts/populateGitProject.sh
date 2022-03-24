#!/bin/bash -x
set -euo pipefail

populateGitlabProject "devops" "nexus3" "${autoSetupHome}/cicd/nexus3/deployment_yaml"
