intellijInstallPlugin() {

    # Get details of zip to download from metadata.json
    export targetFileName=${1:-}
    export sha256Sum=${2:-}
    export downloadUrl=${3:-}

    # Debug log output
    log_debug "targetFileName=${targetFileName}"
    log_debug "sha256Sum=${sha256Sum}"
    log_debug "downloadUrl=${downloadUrl}"

    if [[ -n ${targetFileName} ]] && [[ -n ${sha256Sum} ]] && [[ -n ${downloadUrl} ]]; then

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
    unzip -o ${installationWorkspace}/${targetFileName} -d /home/${baseUser}/intellij-idea/plugins
    sudo chown -R ${baseUser}:${baseUser} /home/${baseUser}/intellij-idea/plugins

    else
        log_debug "Called intellijInstallPlugin() without passing all the parameters. Check your code and try again"

    fi

}