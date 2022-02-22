#!/bin/bash -x
set -euo pipefail

if [[ ${PACKER_BUILDER_TYPE} =~ "vmware-iso"   ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ ${PACKER_BUILDER_TYPE} =~ "parallels"   ]]; then
    export OUTPUT_DIR="parallels"
elif [[ ${PACKER_BUILDER_TYPE} =~ "virtualbox"   ]]; then
    export OUTPUT_DIR="virtualbox"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting export-vmware-ova.sh script"
    exit 1
fi

# if running in Windows WSL, set additional parameter
if [ ! -z ${LOGNAME} ]; then
    export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
fi

# Add box to local Vagrant box library
vagrant box add ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}_metadata.json --force
