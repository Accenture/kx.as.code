#!/bin/bash -x

if [[ "${VM_NAME}" =~ "main" ]]; then
    export OUTPUT_DIR="output-main"
elif [[ "${VM_NAME}" =~ "worker" ]]; then
    export OUTPUT_DIR="output-worker"
elif [[ "${VM_NAME}" =~ "ca" ]]; then
    export OUTPUT_DIR="output-ca"
elif [[ "${VM_NAME}" =~ "vpn" ]]; then
    export OUTPUT_DIR="output-vpn"
else
    echo "Did not recognize built VM -> ${VM_NAME}. Exiting OVA creation script."
    exit
fi

if [[ "${PACKER_BUILDER_TYPE}" =~ "vmware-iso" ]]; then
    export PROVIDER="vmware-desktop"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "vsphere-iso" ]]; then
    export PROVIDER="vmware-vsphere"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "parallels" ]]; then
    export PROVIDER="parallels"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "virtualbox" ]]; then
    export PROVIDER="virtualbox"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting add-vagrant-box script"
    exit 1
fi

# Create VMWare OVA file
ovftool --diskMode=thin --compress=9 --name="${VM_NAME}-${VM_VERSION}" --prop:vendor="Accenture Interactive" --prop:vendorUrl="https://www.accenture.com" --prop:product="KX.AS.CODE" --prop:productUrl="https://github.com/Accenture/kx.as.code" --prop:version="${VM_VERSION}" --prop:fullVersion="${VM_VERSION}" --annotation="OVA version of KX.AS.CODE VMWare Image" "../../../${OUTPUT_DIR}${VM_SUFFIX}/${PROVIDER}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.vmx" "../../../${OUTPUT_DIR}${VM_SUFFIX}/${PROVIDER}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.ova"
