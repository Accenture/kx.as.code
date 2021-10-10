log_error() {
    logFilename=$(setLogFilename)
    echo "$(date '+%Y-%m-%d_%H%M%S') [ERROR] ${1}" | tee -a ${logFilename}
}
