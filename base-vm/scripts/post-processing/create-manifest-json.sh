#!/bin/bash

export PROVIDER=$(echo $PACKER_BUILDER_TYPE | sed 's/-iso//')

if [ -f ../../../boxes/${PROVIDER}/${PACKER_BUILD_NAME}_manifest.json ]; then 
    mv ../../../boxes/${PROVIDER}/${PACKER_BUILD_NAME}_manifest.json ../../../boxes/${PROVIDER}/${PACKER_BUILD_NAME}_manifest.json.previous
fi