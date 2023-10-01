####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
functionStart() {

    local skipFunctionCallCapture=${1:-false}

    # Set functionStart timestamps
    export functionStartFriendlyTimestamp=$(date "+%d-%m-%Y %H:%M:%S")
    export functionStartEpochTimestamp=$(date "+%s.%N")

    # Reset functionEnd timestamps
    local functionEndFriendlyTimestamp=${functionStartFriendlyTimestamp}
    local functionEndEpochTimestamp=${functionStartEpochTimestamp}

    if [[ "${skipFunctionCallCapture}" == "false" ]]; then
        # Reference for notifications
        echo "${FUNCNAME[1]}()" >${installationWorkspace}/.currentFunctionExecuting
    fi

    >&2 log_debug "Entered function ${FUNCNAME[1]}() at ${functionStartFriendlyTimestamp}"

    if [[ "${logLevel}" == "trace" ]]; then
        set -x
    else
        set +x
    fi

    set -eE -o functrace pipefail
    trap 'functionFailure "${LINENO}" "${BASH_COMMAND}" "$?"' ERR

}
