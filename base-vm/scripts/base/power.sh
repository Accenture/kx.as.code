#!/bin/bash -x
set -euo pipefail

# switch off power beats_management
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
