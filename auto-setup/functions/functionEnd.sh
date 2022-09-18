functionStart() {

    >&2 log_debug "Entered function ${FUNCNAME[1]}()"

    if [[ "${logLevel}" == "debug" ]]; then
        set -x
    fi

}