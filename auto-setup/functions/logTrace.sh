log_trace() {
    if [[ "${logLevel}" == "trace" ]]; then
        >&2 echo "$(date '+%Y-%m-%d_%H%M%S') [TRACE] ${1}" | tee -a ${logFilename}
    fi
}
