#!/bin/bash -eux

# Create directories
mkdir -p $HOME/KX_Data/gitlab-ee/gitaly
mkdir -p $HOME/KX_Data/gitlab-ee/postgres
mkdir -p $HOME/KX_Data/gitlab-ee/redis

# Correct ownership
sudo chown -R 1000:1000 $HOME/KX_Data/gitlab-ee/gitaly
sudo chown -R 1001:1001 $HOME/KX_Data/gitlab-ee/postgres
sudo chown -R 1001:1001 $HOME/KX_Data/gitlab-ee/redis
