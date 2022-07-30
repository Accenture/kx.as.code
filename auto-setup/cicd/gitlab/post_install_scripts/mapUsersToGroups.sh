#!/bin/bash
set -euo pipefail

# Map users to groups in Gitlab
gitlabMapUserToGroup "${baseUser}" "kx.as.code"
gitlabMapUserToGroup "${baseUser}" "devops"
