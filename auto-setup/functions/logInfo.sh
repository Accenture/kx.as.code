log_info() {
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]]; then
        echo "$(date '+%Y-%m-%d_%H%M%S') [INFO] ${1}" | tee -a ${logFilename}
    fi
}
