#!/bin/bash -eux

# Create directories
mkdir -p $HOME/KX_Data/gitlab-ce/gitaly
mkdir -p $HOME/KX_Data/gitlab-ce/postgres
mkdir -p $HOME/KX_Data/gitlab-ce/redis

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/gitlab-ce/gitaly
sudo chown -R 1001:1001 $HOME/KX_Data/gitlab-ce/postgres
sudo chown -R 1001:1001 $HOME/KX_Data/gitlab-ce/redis
