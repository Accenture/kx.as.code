log_warn() {
    echo "$(date '+%Y-%m-%d_%H%M%S') [WARN] ${1}" | tee -a ${logFilename}
}
