#!/bin/bash
set -euo pipefail

# Get Mattermost team id
kxascodeTeamId=$(mattermostGetTeamId "kxascode")

# Add Channels
mattermostCreateChannel "Security" "${kxascodeTeamId}"
mattermostCreateChannel "CICD" "${kxascodeTeamId}"
mattermostCreateChannel "Monitoring" "${kxascodeTeamId}"
