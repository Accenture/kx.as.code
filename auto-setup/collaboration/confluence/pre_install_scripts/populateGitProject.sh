#!/bin/bash -x
set -euo pipefail

populateGitlabProject "devops" "confluence" "${autoSetupHome}/collaboration/confluence/deployment_yaml"
