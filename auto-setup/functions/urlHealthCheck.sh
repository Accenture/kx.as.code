checkUrlHealth() {

  urlToCall=${1}
  expectedHttpResponseCode=${2}
  curlAuthOption=${3}

  export urlStatus="NOK"

  for i in {1..20}; do
      http_code=$(curl ${curlAuthOption} -s -o /dev/null -L -w '%{http_code}' ${urlToCall} || true)
      if [[ "${http_code}" == "${expectedHttpResponseCode}" ]]; then
          log_info "URL \"${urlToCall}\" seems healthy. Received expected response [RC=${http_code}]"
          export export urlStatus="OK"
          break
      fi
      log_info "Waiting for ${urlToCall} [Got RC=${http_code}, Expected RC=${expectedHttpResponseCode}]"
      sleep 15
  done

  if [[ ${urlStatus} == "NOK" ]]; then
    log_error "Health checks for ${urlToCall} ended in error. Check the logs and try again"
  fi

}