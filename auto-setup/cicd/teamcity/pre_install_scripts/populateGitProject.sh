#!/bin/bash
set -euo pipefail

# TODO - make this optional depending on whether Gitlab is installed or not
populateGitlabProject "devops" "teamcity" "${autoSetupHome}/cicd/teamcity/deployment_yaml"