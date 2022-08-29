functionEnd() {

    if [[ "${logLevel}" == "debug" ]]; then
        set +x
    fi
    
    >&2 log_debug "Exited function ${FUNCNAME[1]}()"

}