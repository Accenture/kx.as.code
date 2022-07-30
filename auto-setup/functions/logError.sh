log_error() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [ERROR] ${1}" | tee -a ${logFilename}
}
