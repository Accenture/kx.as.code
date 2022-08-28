log_debug() {
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] ${1}" | tee -a ${logFilename}
    fi
}
