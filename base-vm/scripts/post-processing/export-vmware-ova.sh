#!/bin/bash

# Create VMWare OVA file
# TODO - Differentiate between main and worker nodes and change internal Packer variables to environment variables
ovftool --diskMode=thin --compress=9 --name="kx.as.code-{{user `version`}}" --prop:vendor="Accenture Interactive" --prop:vendorUrl="https://www.accenture.com" --prop:product="KX.AS.CODE" --prop:productUrl="https://innersource.accenture.com/projects/KXAS\" --prop:version=\"{{user `version`}}\" --prop:fullVersion=\"{{user `version`}}\" --annotation=\"OVA version of KX.AS.CODE VMWare Image." "output/vmware/kx.as.code-{{user `version`}}.vmx" "output/vmware/kx.as.code-{{user `version`}}.ova"



