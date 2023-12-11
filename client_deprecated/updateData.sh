#!/bin/bash -x

export rootRepoDir=$(git rev-parse --show-toplevel)

# Copy app images to client's appImgs
find ${rootRepoDir}/auto-setup -type f -name "*.png" ! -name "*screenshot*" -exec cp {} ${rootRepoDir}/client/src/media/png/appImgs \;

# Copy app images to client's screenshots
find ${rootRepoDir}/auto-setup -type f -name "*screenshot*" -exec cp {} ${rootRepoDir}/client/src/media/png/screenshots \;

# Generate combined metadata json
cd ${rootRepoDir}/auto-setup
jq -s 'flatten' */*/metadata.json > ${rootRepoDir}/client/src/data/combined-metadata-files.json

# Generate combined group json
cd  ${rootRepoDir}
jq -s 'flatten' templates/aq*.json > ${rootRepoDir}/client/src/data/combined-application-group-files.json 

# Copy updated version.json
cp -f ${rootRepoDir}/versions.json ${rootRepoDir}/client/src/data/
