log_debug() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] ${1}" | tee -a ${logFilename}
}
