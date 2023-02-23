functionStart() {

    local skipFunctionCallCapture=${1:-false}

    # Set functionStart timestamps
    export functionStartFriendlyTimestamp=$(date "+%d-%m-%Y %H:%M:%S")
    export functionStartEpochTimestamp=$(date "+%s.%N")

    # Reset functionEnd timestamps
    local functionEndFriendlyTimestamp=${functionStartFriendlyTimestamp}
    local functionEndEpochTimestamp=${functionStartEpochTimestamp}

    if [[ "${skipFunctionCallCapture}" != "true" ]]; then
        # Reference for notifications
        echo "${FUNCNAME[1]}()" >${installationWorkspace}/.currentFunctionExecuting
    fi

    >&2 log_debug "Entered function ${FUNCNAME[1]}() at ${functionStartFriendlyTimestamp}"

    if [[ "${logLevel}" == "debug" ]]; then
        set -x
    fi



}