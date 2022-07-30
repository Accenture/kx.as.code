#!/bin/bash
set -euo pipefail

# Call bash functions to map users to team
mattermostMapUserToTeam "admin" "kxascode"
mattermostMapUserToTeam "securty" "kxascode"
mattermostMapUserToTeam "cicd" "kxascode"
mattermostMapUserToTeam "monitoring" "kxascode"
