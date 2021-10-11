log_debug() {
    logFilename=$(setLogFilename)
    echo "$(date '+%Y-%m-%d_%H%M%S') [DEBUG] ${1}" | tee -a ${logFilename}
}
