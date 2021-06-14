#!/bin/bash -x
set -euo pipefail

# Execute Kubernetes Cluster Validation Tests (add --mode quick for a quick test)
$HOME/sonobuoy/sonobuoy run --wait

# Get Test Results
results=$($HOME/sonobuoy/sonobuoy retrieve)
$HOME/sonobuoy/sonobuoy results $results

# Delete Test Installation
$HOME/sonobuoy/sonobuoy delete --wait
