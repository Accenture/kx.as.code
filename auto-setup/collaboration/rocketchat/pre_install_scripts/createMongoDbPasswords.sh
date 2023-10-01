#!/bin/bash

# Create mongodb USER password or use existing if it already exists
export mongodbUserPassword=$(managedApiKey "rocketchat-mongodb-user-password" "rocketchat")

# Create mongodb ROOT password or use existing if it already exists
export mongodbRootPassword=$(managedApiKey "rocketchat-mongodb-root-password" "rocketchat")
