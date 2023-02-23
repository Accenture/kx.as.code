log_debug() {
    if [[ "${logLevel}" == "debug" ]]; then
        >&2 echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] ${1}" | tee -a ${logFilename}
    fi
}
