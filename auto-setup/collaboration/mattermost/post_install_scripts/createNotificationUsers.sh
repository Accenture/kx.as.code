#!/bin/bash
set -euo pipefail

mattermostCreateUser "security"
mattermostCreateUser "cicd"
mattermostCreateUser "monitoring"
