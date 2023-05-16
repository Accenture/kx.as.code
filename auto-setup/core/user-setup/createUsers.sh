#!/bin/bash
set -euox pipefail

# Call function for creating users
# Note: Feature externalized to function so it can be called separately outside of the framework using the manual execution wrapper
createUsers