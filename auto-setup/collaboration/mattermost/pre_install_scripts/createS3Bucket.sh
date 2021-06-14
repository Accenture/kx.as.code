#!/bin/bash -x
set -euo pipefail

bucketExists=$(mc ls  minio --insecure --json | jq '. | select(.key=="mattermost-file-storage/")')
if [[ -z ${bucketExists} ]]; then
    mc mb minio/mattermost-file-storage --insecure
fi
