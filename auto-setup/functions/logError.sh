####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
log_error() {

  local callerLine=$(caller | awk '{ print $1 }')
  local callerName=$(basename "$(caller | awk '{ print $2 }')" ".sh")

  if [[ -n ${1} ]]; then
    if [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "debug" ]] || [[ "${logLevel}" == "trace" ]]; then
      >&2 echo -e "[ERROR] (${callerName}) ${1}" | tee -a ${logFilename}
      notifyAllChannels "${1}" "error" "failed" "${action}" "${payload}" "${2:-}"
      exit 1
    fi
  fi

}
