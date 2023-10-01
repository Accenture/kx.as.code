#!/bin/bash

# Get Gitlab personal access token
export personalAccessToken=$(getPassword "gitlab-personal-access-token" "gitlab")

# Create Groups in Gitlab
gitlabCreateGroup "kx.as.code"
gitlabCreateGroup "devops"
