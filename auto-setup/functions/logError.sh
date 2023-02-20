log_error() {
    if [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo "$(date '+%Y-%m-%d_%H%M%S') [ERROR] ${1}" | tee -a ${logFilename}
    fi
}
