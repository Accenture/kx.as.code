log_warn() {
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]]; then
        echo "$(date '+%Y-%m-%d_%H%M%S') [WARN] ${1}" | tee -a ${logFilename}
    fi
}
