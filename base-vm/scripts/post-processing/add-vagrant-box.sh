#!/bin/bash -x

# if running in Windows WSL, set additional parameter
if [ ! -z ${LOGNAME} ]; then
    export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
fi

export PROVIDER=$(echo ${PACKER_BUILDER_TYPE} | sed 's/-iso//')

# Add box to local Vagrant box library
vagrant box add ${PACKER_BUILD_NAME} ../../../boxes/${PROVIDER}/${BOX_NAME}.box --force
