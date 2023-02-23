autoSetupErrorHandler() {

    local rc=${1}
    local command="${2}"
    local callerScript="${3}"

    # Handle error
    if [[ ${rc} -ne 0 ]]; then
        log_error "The last command ''${command}'' triggered by ''${callerScript}'' ended in a non-zero return code. Exiting with RC=''${rc}''"
        setRetryDataFailureState
        exit ${rc}
    fi

}