#!/bin/bash

# Call function to prune docker registry
pruneDockerRegistry

# Clean up local file system as well
docker system prune --force