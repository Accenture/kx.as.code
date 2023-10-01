####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
logStreamFormatToFile() {

  set +x

  while read data; do
    printf '%s\n' "$(date --utc +%FT%TZ) ${data}" >>${autoSetupLogFilename}
  done

  set -x

}
