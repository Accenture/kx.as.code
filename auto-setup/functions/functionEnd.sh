functionEnd() {

    if [[ "${logLevel}" == "debug" ]]; then
        set +x
    fi

    local functionEndFriendlyTimestamp=$(date "+%d-%m-%Y %H:%M:%S")
    local functionEndEpochTimestamp=$(date "+%s.%N")
    local functionExecutionDuration=$(calculateDuration "${functionStartEpochTimestamp}" "${functionEndEpochTimestamp}")
    # Erase function reference for notifications
    echo "" >${installationWorkspace}/.currentFunctionExecuting

    >&2 log_debug "Exited function ${FUNCNAME[1]}() ${functionEndFriendlyTimestamp}"
    >&2 log_debug "${FUNCNAME[1]}() ran for a duration of ${functionExecutionDuration}"

}