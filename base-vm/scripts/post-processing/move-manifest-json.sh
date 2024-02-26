#!/bin/bash -x
set -euo pipefail

export PROVIDER=$(echo ${PACKER_BUILDER_TYPE} | sed 's/-iso//g')

if [[ ${VM_NAME} =~ "main"   ]]; then
    export KX_VM_TYPE="main"
elif [[ ${VM_NAME} =~ "node"   ]]; then
    export KX_VM_TYPE="node"
else
    echo "Packer build name ${VM_NAME} not recognized. Exiting move-manifest.sh script"
    exit 1
fi

if [[ ${PACKER_BUILDER_TYPE} =~ "vmware-iso"   ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ ${PACKER_BUILDER_TYPE} =~ "parallels-iso"   ]]; then
    export OUTPUT_DIR="parallels"
elif [[ ${PACKER_BUILDER_TYPE} =~ "virtualbox-iso"   ]]; then
    export OUTPUT_DIR="virtualbox"
elif [[ ${PACKER_BUILDER_TYPE} =~ "qemu"   ]]; then
    export OUTPUT_DIR="qemu"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting move-manifest.sh script"
    exit 1
fi

if [[ -f ../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}_manifest.json ]]; then
    mv ../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}_manifest.json.previous
fi

if [[ -f ${VM_NAME}-${VM_VERSION}_manifest.json ]]; then
    mv ${VM_NAME}-${VM_VERSION}_manifest.json ../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}_manifest.json
fi
