#!/bin/bash -x

vmName="{{user `vm_name`}}"
if [[ "${vmName}" =~ "main" ]]; then
    export outputRootDir="output-main"
elif [[ "${vmName}" =~ "worker" ]]; then
    export outputRootDir="output-worker"
elif [[ "${vmName}" =~ "ca" ]]; then
    export outputRootDir="output-ca"
elif [[ "${vmName}" =~ "vpn" ]]; then
    export outputRootDir="output-vpn"
else
    echo "Did not recognize built VM -> ${vmName}. Exiting OVA creation script."
    exit
fi

# Create VMWare OVA file
ovftool --diskMode=thin --compress=9 --name="{{user `vm_name`}}-{{user `version`}}" --prop:vendor="Accenture Interactive" --prop:vendorUrl="https://www.accenture.com" --prop:product="KX.AS.CODE" --prop:productUrl="https://github.com/Accenture/kx.as.code" --prop:version="{{user `version`}}" --prop:fullVersion="{{user `version`}}" --annotation="OVA version of KX.AS.CODE VMWare Image" "../../../${outputRootDir}{{user `vm_suffix`}}/vmware-desktop-{{user `version`}}/{{user `vm_name`}}-{{user `version`}}.vmx" "../../../${outputRootDir}{{user `vm_suffix`}}/vmware-desktop-{{user `version`}}/{{user `vm_name`}}-{{user `version`}}.ova"
