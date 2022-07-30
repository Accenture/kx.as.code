#!/bin/bash
set -euo pipefail

populateGitlabProject "kx.as.code" "kx.as.code" "${sharedGitHome}/kx.as.code" "node_modules pnpm-lock.yaml .npm .forever"
