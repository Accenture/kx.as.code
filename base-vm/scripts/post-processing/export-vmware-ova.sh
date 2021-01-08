#!/bin/bash -x

if [[ "${VM_NAME}" =~ "main" ]]; then
    export ${OUTPUT_ROOT_DIR}="output-main"
elif [[ "${VM_NAME}" =~ "worker" ]]; then
    export ${OUTPUT_ROOT_DIR}="output-worker"
elif [[ "${VM_NAME}" =~ "ca" ]]; then
    export ${OUTPUT_ROOT_DIR}="output-ca"
elif [[ "${VM_NAME}" =~ "vpn" ]]; then
    export ${OUTPUT_ROOT_DIR}="output-vpn"
else
    echo "Did not recognize built VM -> ${VM_NAME}. Exiting OVA creation script."
    exit
fi

# Create VMWare OVA file
ovftool --diskMode=thin --compress=9 --name="${VM_NAME}-${VM_VERSION}" --prop:vendor="Accenture Interactive" --prop:vendorUrl="https://www.accenture.com" --prop:product="KX.AS.CODE" --prop:productUrl="https://github.com/Accenture/kx.as.code" --prop:version="${VM_VERSION}" --prop:fullVersion="${VM_VERSION}" --annotation="OVA version of KX.AS.CODE VMWare Image" "../../../${${OUTPUT_ROOT_DIR}}${VM_SUFFIX}/vmware-desktop-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.vmx" "../../../${${OUTPUT_ROOT_DIR}}${VM_SUFFIX}/vmware-desktop-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.ova"
