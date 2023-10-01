####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
log_trace() {

    local callerLine=$(caller | awk '{ print $1 }')
    local callerName=$(basename "$(caller | awk '{ print $2 }')" ".sh")

    if [[ -n ${1} ]]; then
        if [[ "${logLevel}" == "trace" ]]; then
            >&2 echo -e "[TRACE] (${callerName}) ${1}" | tee -a ${logFilename}
        fi
    fi

}
