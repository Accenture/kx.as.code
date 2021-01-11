#!/bin/bash -x

if [[ "${PACKER_BUILDER_TYPE}" =~ "vmware-iso" ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "parallels" ]]; then
    export OUTPUT_DIR="parallels"
elif [[ "${PACKER_BUILDER_TYPE}" =~ "virtualbox" ]]; then
    export OUTPUT_DIR="virtualbox"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting create-info.sh script"
    exit 1
fi


if [[ ! -d ../../../boxes/${OUTPUT_DIR}-${VM_VERSION} ]]; then
    mkdir -p ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}
fi

cp ../../../templates/info.template ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/info.json

# Check is running from Mac (Darwin) or Linux (including WSL and Windows Git Bash)
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/##USERNAME##/Accenture Interactive/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/info.json
else
    sed -i "s/##USERNAME##/Accenture Interactive/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/info.json
fi
