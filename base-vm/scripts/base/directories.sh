#!/bin/bash -x
set -euo pipefail

# Create base directories
sudo mkdir -p ${KX_HOME}/skel
sudo mkdir -p ${KX_HOME}/git
sudo mkdir -p ${KX_HOME}/workspace

# Make permissions world writable during initial build
sudo chmod -R 777 ${KX_HOME}
