#!/bin/bash
set -euo pipefail

populateGitlabProject "devops" "jira" "${autoSetupHome}/collaboration/jira/deployment_yaml"