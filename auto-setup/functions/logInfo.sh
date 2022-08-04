log_info() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [INFO] ${1}" | tee -a ${logFilename}
}
