log_warn() {
    if [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo "$(date '+%Y-%m-%d_%H%M%S') [WARN] ${1}" | tee -a ${logFilename}
    fi
}
