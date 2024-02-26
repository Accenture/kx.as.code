#!/bin/bash -x
set -euo pipefail

if [[ ${PACKER_BUILDER_TYPE} =~ "vmware-iso"   ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ ${PACKER_BUILDER_TYPE} =~ "parallels"   ]]; then
    export OUTPUT_DIR="parallels"
elif [[ ${PACKER_BUILDER_TYPE} =~ "virtualbox"   ]]; then
    export OUTPUT_DIR="virtualbox"
elif [[ ${PACKER_BUILDER_TYPE} =~ "qemu"   ]]; then
    export OUTPUT_DIR="qemu"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting export-vmware-ova.sh script"
    exit 1
fi

if [[ ${VM_NAME} =~ "main"   ]]; then
    export KX_VM_TYPE="main"
elif [[ ${VM_NAME} =~ "node"   ]]; then
    export KX_VM_TYPE="node"
else
    echo "Packer build name ${VM_NAME} not recognized. Exiting move-manifest.sh script"
    exit 1
fi

# Create VMWare OVA file
ovftool --diskMode=thin --compress=9 --name="${VM_NAME}-${VM_VERSION}" --prop:vendor="KX.AS.CODE" --prop:vendorUrl="https://github.com/Accenture/kx.as.code" --prop:product="KX.AS.CODE" --prop:productUrl="https://github.com/Accenture/kx.as.code" --prop:version="${VM_VERSION}" --prop:fullVersion="${VM_VERSION}" --annotation="OVA version of KX.AS.CODE VMWare Image" "../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.vmx" "../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.ova"
