functionStart() {

    export functionStartFriendlyTimestamp=$(date "+%d-%m-%Y %H:%M:%S")
    export functionStartEpochTimestamp=$(date "+%s.%N")
    # Reference for notifications
    echo "${FUNCNAME[1]}()" >${installationWorkspace}/.currentFunctionExecuting

    >&2 log_debug "Entered function ${FUNCNAME[1]}() at ${functionStartFriendlyTimestamp}"

    if [[ "${logLevel}" == "debug" ]]; then
        set -x
    fi



}