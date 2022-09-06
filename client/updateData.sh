#!/bin/bash -x

export rootRepoDir=$(git rev-parse --show-toplevel)

# Generate combined metadata json
cd ${rootRepoDir}/auto-setup
jq -s 'flatten' */*/metadata.json > ${rootRepoDir}/client/src/data/combined-metadata-files.json

# Generate combined gorup json
cd  ${rootRepoDir}
jq -s 'flatten' templates/aq*.json > ${rootRepoDir}/client/src/data/combined-application-group-files.json 

# Copy updated version.json
cp -f ${rootRepoDir}/versions.json ${rootRepoDir}/client/src/data/
