#!/bin/bash -x
set -euo pipefail

# Set label on main node to ensure controller is deployed there
/usr/bin/sudo kubectl label nodes $(hostname) ingress-controller=true --overwrite=true
