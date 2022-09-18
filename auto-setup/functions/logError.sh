log_error() {
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]]; then
        echo "$(date '+%Y-%m-%d_%H%M%S') [ERROR] ${1}" | tee -a ${logFilename}
    fi
}
