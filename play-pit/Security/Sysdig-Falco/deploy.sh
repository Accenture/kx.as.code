#!/bin/bash -x
set -euo pipefail

# Download script included in falco-extras for creating custom rules file for helm upgrade
if [ ! -d falco-extras ]; then
    git clone https://github.com/draios/falco-extras
else
    cd falco-extras
    git pull
    cd -
fi

# Execute script for creatime sysdig-falco rules file for Helm
falco-extras/scripts/rules2helm ./falco_rules.local.yaml > ./custom-rules.yaml

# Merge the custom rules file with the values file
cat values.yaml custom-rules.yaml > values_custom_rules.yaml

# Perform the helm upgade with the generated custom rules and values file
helm upgrade --install sysdig-falco stable/falco -f values_custom_rules.yaml --version 1.1.0
