#!/bin/bash -x
set -euo pipefail

if [[ ${PACKER_BUILDER_TYPE} =~ "vmware-iso"   ]]; then
    export OUTPUT_DIR="vmware-desktop"
elif [[ ${PACKER_BUILDER_TYPE} =~ "parallels"   ]]; then
    export OUTPUT_DIR="parallels"
elif [[ ${PACKER_BUILDER_TYPE} =~ "virtualbox"   ]]; then
    export OUTPUT_DIR="virtualbox"
else
    echo "Packer build type ${PACKER_BUILDER_TYPE} not recognized. Exiting create-info.sh script"
    exit 1
fi

export PROVIDER=$(echo ${OUTPUT_DIR} | sed 's/-/_/g')

export CHECKSUM=$(shasum -a 512 ..\/..\/..\/boxes\/${OUTPUT_DIR}-${VM_VERSION}\/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box | awk '{ print $1 }')

if [[ ! -d ../../../boxes/${OUTPUT_DIR}-${VM_VERSION} ]]; then
    mkdir -p ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}
fi

if [[ -f ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json ]]; then
    mv ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous
fi

cp ../../../templates/metadata.template ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json

# Check is running from Mac (Darwin) or Linux (including WSL and Windows Git Bash)
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/##NAME##/${PACKER_BUILD_NAME}/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i '' "s/##DESCRIPTION##/Accenture Interactive KX.AS.CODE DevOps VM - PLAY LEARN INNOVATE/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i '' "s/##VERSION##/${VM_VERSION}/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i '' "s/##PROVIDER##/${PROVIDER}/g" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i '' "s/##URL##/..\/..\/..\/boxes\/${OUTPUT_DIR}-${VM_VERSION}\/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i '' "s/##CHECKSUM##/${CHECKSUM}/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
else
    sed -i "s/##NAME##/${PACKER_BUILD_NAME}/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i "s/##DESCRIPTION##/Accenture Interactive KX.AS.CODE DevOps VM - PLAY LEARN INNOVATE/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i "s/##VERSION##/${VM_VERSION}/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i "s/##PROVIDER##/${PROVIDER}/g" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i "s/##URL##/..\/..\/..\/boxes\/${OUTPUT_DIR}-${VM_VERSION}\/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
    sed -i "s/##CHECKSUM##/${CHECKSUM}/" ../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
fi
