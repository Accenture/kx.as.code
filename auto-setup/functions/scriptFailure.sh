####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
scriptFailure() {

  local lineno="$1"
  local msg="$2"
  local script="$3"
  local rc="$4"
  escapedMsg="$(echo "$msg" | sed 's;$(;\\\\$(;g' | sed "s;';'';g" | sed 's;";\";g')"
  expandedMsg="$(echo "$escapedMsg" | envsubst)"
  local callerLine=$(caller | awk '{ print $1 }')
  local callerName=$(caller | awk '{ print $2 }')
  log_error "Script ${callerName} failed at line ${callerLine} with rc=${rc}: $expandedMsg"
  exit ${rc}

}

