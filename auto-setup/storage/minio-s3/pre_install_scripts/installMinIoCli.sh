#!/bin/bash -x
set -euo pipefail

# Install MinIO command line tool (mc) if not yet install
if [ ! -f /usr/local/bin/mc ]; then
    curl --output mc https://dl.min.io/client/mc/release/linux-amd64/mc
    # Give MC execute permissions
    chmod +x mc
    # Move to bin folder on path
    /usr/bin/sudo mv mc /usr/local/bin
fi
