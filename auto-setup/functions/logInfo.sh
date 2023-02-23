log_info() {
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo "$(date '+%Y-%m-%d_%H%M%S') [INFO] ${1}" | tee -a ${logFilename}
    fi
}
