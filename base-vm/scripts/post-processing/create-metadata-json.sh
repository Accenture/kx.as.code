#!/bin/bash -x

export PROVIDERDIR=$(echo $PACKER_BUILDER_TYPE | sed 's/-iso//')

if [ "$PROVIDER" = "vmware" ]; then 
    export PROVIDER=vmware_desktop
else 
    export PROVIDER=$PROVIDERDIR
fi

export CHECKSUM=$(shasum -a 512 ..\/..\/..\/boxes\/${PROVIDERDIR}\/$PACKER_BUILD_NAME.box | awk '{ print $1 }')

if [ ! -d ../../../boxes/${PROVIDERDIR} ]; then 
    mkdir -p ../../../boxes/${PROVIDERDIR}
fi

if [ -f ../../../boxes/manifest.json ]; then
    mv ../../../boxes/manifest.json boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_manifest.json
fi

if [ -f ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json ]; then 
    mv ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json.previous
fi

cp ../../../templates/metadata.template ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json

# Check is running from Mac (Darwin) or Linux (including WSL and Windows Git Bash)
if [ "$(uname)" == "Darwin" ]; then
    sed -i '' "s/##NAME##/$PACKER_BUILD_NAME/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i '' "s/##DESCRIPTION##/Accenture Interactive KX.AS.CODE DevOps VM - PLAY LEARN INNOVATE/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i '' "s/##VERSION##/$VERSION/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i '' "s/##PROVIDER##/$PROVIDER/g" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i '' "s/##URL##/boxes\/$PROVIDERDIR\/$PACKER_BUILD_NAME.box/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i '' "s/##CHECKSUM##/$CHECKSUM/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
else
    sed -i "s/##NAME##/$PACKER_BUILD_NAME/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i "s/##DESCRIPTION##/Accenture Interactive KX.AS.CODE DevOps VM - PLAY LEARN INNOVATE/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i "s/##VERSION##/$VERSION/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i "s/##PROVIDER##/$PROVIDER/g" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i "s/##URL##/boxes\/$PROVIDERDIR\/$PACKER_BUILD_NAME.box/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
    sed -i "s/##CHECKSUM##/$CHECKSUM/" ../../../boxes/${PROVIDERDIR}/${PACKER_BUILD_NAME}_metadata.json
fi