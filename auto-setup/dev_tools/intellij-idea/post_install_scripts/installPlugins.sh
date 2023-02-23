#!/bin/bash
set -euo pipefail

local numberOfPluginsToInstall=$(($(cat ${componentMetadataJson} | jq '.plugins_to_install | length') -1))
local i
for (( i=0; i<=${numberOfPluginsToInstall}; i++ ))
do

    pluginAttributes=$(cat ${componentMetadataJson} | jq -r '.plugins_to_install['${i}']')

    # Get details of zip to download from metadata.json
    export targetFileName="intellij-$(echo ${pluginAttributes} | jq -r '.name')-plugin.zip"
    export sha256Sum=$(echo ${pluginAttributes} | jq -r '.sha256Sum')
    export downloadUrl=$(echo ${pluginAttributes} | jq -r '.downloadUrl')

    # Debug log output
    log_debug "targetFileName=${targetFileName}"
    log_debug "sha256Sum=${sha256Sum}"
    log_debug "downloadUrl=${downloadUrl}"

    # Download content package from Artifactory
    downloadFile "${downloadUrl}" \
        "${sha256Sum}" \
        "${installationWorkspace}/${targetFileName}" || rc=$?
    if [[ ${rc} -ne 0 ]]; then
        log_error "Downloading ${targetFileName} returned with (${rc}). Exiting with RC=${rc}"
        message="ERROR: Could not download the IntelliJ plugin - ${targetFileName}"
        notifyAllChannels "${message}" "error" "failed" "" "" "" "600000"
        exit ${rc}
    fi

    # Unzip plugin to IntelliJ plugins folder
    unzip ${installationWorkspace}/${targetFileName} -d /home/kx.hero/intellij-idea/plugins

done