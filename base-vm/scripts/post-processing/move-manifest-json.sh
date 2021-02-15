#!/bin/bash -x
set -o pipefail

export PROVIDER=${PACKER_BUILDER_TYPE//-iso/}

if [[ "${VM_NAME}" =~ "main" ]]; then
    export KX_VM_TYPE="main"
elif [[ "${VM_NAME}" =~ "worker" ]]; then
    export KX_VM_TYPE="worker"
else
    echo "Packer build name ${VM_NAME} not recognized. Exiting move-manifest.sh script"
    exit 1
fi

if [[ "${PACKER_BUILDER_TYPE}" =~ "vmware-iso" ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "parallels-iso" ]]; then
    export OUTPUT_DIR="parallels"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "virtualbox-iso" ]]; then
    export OUTPUT_DIR="virtualbox"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting move-manifest.sh script"
    exit 1
fi


if [[ -f ../../../output-${KX_VM_TYPE}${VM_SUFFIX}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json ]]; then
    mv "../../../output-${KX_VM_TYPE}${VM_SUFFIX}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json" "../../../output-${KX_VM_TYPE}${VM_SUFFIX}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json.previous"
fi

if [[ -f ${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json ]]; then
    mv "${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json" "../../../output-${KX_VM_TYPE}${VM_SUFFIX}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json"
fi
