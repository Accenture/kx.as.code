#!/bin/bash -eux

# Create and export passwords variables for later mustache substitution
export nextcloudPostgresqlPassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)
