#!/bin/bash
set -euo pipefail

populateGitlabProject "devops" "teamcity" "${autoSetupHome}/cicd/teamcity/deployment_yaml"