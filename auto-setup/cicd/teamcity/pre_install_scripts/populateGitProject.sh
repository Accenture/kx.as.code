#!/bin/bash
set -euox pipefail

populateGitlabProject "devops" "teamcity" "${autoSetupHome}/cicd/teamcity/deployment_yaml"
