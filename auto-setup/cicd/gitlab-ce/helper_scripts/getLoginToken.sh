#!/bin/bash

# Create OAUTH application in Gitlab for Grafana
export personalAccessToken=$(cat /home/${vmUser}/.config/kx.as.code/.admin.gitlab.pat)
