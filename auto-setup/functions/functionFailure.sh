####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
functionFailure() {

  local lineno=$1
  local msg=$2
  local rc=$3
  local function=${FUNCNAME[1]}
  escapedMsg=$(echo "$msg" | sed 's;$(;\\\\$(;g' | sed "s;';'';g" | sed 's;";\\\\";g')
  expandedMsg=$(eval echo "$escapedMsg")  
  local callerLine=$(caller | awk '{ print $1 }')
  local callerName=$(caller | awk '{ print $2 }')
  log_error "Script ${callerName} failed at line ${callerLine} with rc=${rc}: ${expandedMsg}"
  exit ${rc}

}
