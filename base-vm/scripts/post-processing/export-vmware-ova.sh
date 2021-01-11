#!/bin/bash -x

export PROVIDER=$(echo ${PACKER_BUILDER_TYPE} | sed 's/-iso//g')

if [[ "${PACKER_BUILDER_TYPE}" =~ "vmware-iso" ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "parallels" ]]; then
    export OUTPUT_DIR="parallels"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "virtualbox" ]]; then
    export OUTPUT_DIR="virtualbox"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting export-vmware-ova.sh script"
    exit 1
fi

if [[ "${VM_NAME}" =~ "main" ]]; then
    export KX_VM_TYPE="main"
elif [[ "${VM_NAME}" =~ "worker" ]]; then
    export KX_VM_TYPE="worker"
else
    echo "Packer build name ${VM_NAME} not recognized. Exiting move-manifest.sh script"
    exit 1
fi

# Create VMWare OVA file
ovftool --diskMode=thin --compress=9 --name="${VM_NAME}-${VM_VERSION}" --prop:vendor="Accenture Interactive" --prop:vendorUrl="https://www.accenture.com" --prop:product="KX.AS.CODE" --prop:productUrl="https://github.com/Accenture/kx.as.code" --prop:version="${VM_VERSION}" --prop:fullVersion="${VM_VERSION}" --annotation="OVA version of KX.AS.CODE VMWare Image" "../../../output-${KX_VM_TYPE}${VM_SUFFIX}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.vmx" "../../../output-${KX_VM_TYPE}${VM_SUFFIX}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.ova"
