####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
logStreamFormatToStdOut() {

  set +x

  local alternativeIdentifier=${1:-}
  local callerLine=$(caller | awk '{ print $1 }')
  local callerName=$(basename "$(caller | awk '{ print $2 }')" ".sh")

  if [[ -z ${alternativeIdentifier} ]]; then
    alternativeIdentifier="${callerName}"
  fi

  while read data; do
    printf '%s\n' "(${alternativeIdentifier}) ${data}"
  done

  set -x

}
