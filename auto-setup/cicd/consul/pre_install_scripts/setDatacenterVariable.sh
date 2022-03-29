#!/bin/bash
set -euo pipefail

export dataCenterName=$(echo "${componentName}.${baseDomain}" | sed 's/\./-/g')
