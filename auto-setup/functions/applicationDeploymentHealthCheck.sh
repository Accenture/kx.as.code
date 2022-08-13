applicationDeploymentHealthCheck() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # URL READINESS HEALTH CHECK
  applicationUrls=$(cat ${componentMetadataJson} | jq -r '.urls[]?.url?' | mo)

  for applicationUrl in ${applicationUrls}; do
      readinessCheckData=$(cat ${componentMetadataJson} | jq -r '.urls[0]?.healthchecks?.readiness?')
      urlCheckPath=$(echo ${readinessCheckData} | jq -r '.http_path')
      authorizationRequired=$(echo ${readinessCheckData} | jq -r '.http_auth_required')
      expectedHttpResponseCode=$(echo ${readinessCheckData} | jq -r '.expected_http_response_code')
      expectedContentString=$(echo ${readinessCheckData} | jq -r '.expected_http_response_string')
      expectedJsonValue=$(echo ${readinessCheckData} | jq -r '.expected_json_response.json_value')
      curlAuthOption=""

      # Set default if not defined in metadata.json
      if [[ -z ${expectedHttpResponseCode} ]]; then
        expectedHttpResponseCode="200" 
      fi

      # Set curl auth option, if http_auth_required=true in solution's metadata.json
      if [[ "${authorizationRequired}" == "true" ]]; then
          httpAuthSecretName=$(echo ${readinessCheckData} | jq -r '.http_auth_secret.secret_name?')
          httpAuthUsernameField=$(echo ${readinessCheckData} | jq -r '.http_auth_secret.username_field?')
          httpAuthUsername=$(kubectl get secret -n ${namespace} ${httpAuthSecretName} -o json | jq -r '.data.'${httpAuthUsernameField}'' | base64 --decode)
          httpAuthPasswordField=$(echo ${readinessCheckData} | jq -r '.http_auth_secret.password_field?')
          httpAuthPassword=$(kubectl get secret -n ${namespace} ${httpAuthSecretName} -o json | jq -r '.data.'${httpAuthPasswordField}'' | base64 --decode)
          curlAuthOption="-u ${httpAuthUsername}:${httpAuthPassword}"
      fi

      for i in {1..60}; do
          http_code=$(curl ${curlAuthOption} -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath} || true)
          if [[ "${http_code}" == "${expectedHttpResponseCode}" ]]; then
              echo "Application \"${componentName}\" is up. Received expected response [RC=${http_code}]"
              break
          fi
          log_info "Waiting for ${applicationUrl}${urlCheckPath} [Got RC=${http_code}, Expected RC=${expectedHttpResponseCode}]"
          sleep 30
      done

      finalReturnCode=$(curl ${curlAuthOption} -s -o /dev/null -L -w '%{http_code}' ${applicationUrl}${urlCheckPath})
      if [[ ${finalReturnCode} -ne ${expectedHttpResponseCode} ]]; then
          log_warn "Final health check (60/60) of URL ${applicationUrl} failed. Expected RC ${expectedHttpResponseCode}, but got RC ${finalReturnCode} instead"
      fi

      if [[ -n ${expectedContentString} ]]; then
          for i in {1..5}; do
              returnedContent=$(curl -s -L ${applicationUrl}${urlCheckPath})
              if [[ ${expectedContentString} =~ ${returnedContent} ]]; then
                  log_info "Expected content matched returned health check content, exiting loop"
                  break
              else
                  log_warn "Expected content did not match returned health check content, continuing to check (check ${i} of 5)"
              fi
          done
      fi

      # If expected JSON response is not empty, then check it
      if [[ -n ${expectedJsonValue} ]]; then
          for i in {1..5}; do
              jsonPath=$(echo ${readinessCheckData} | jq -r '.expected_json_response.json_path')
              returnedContent=$(curl -s -L ${applicationUrl}${urlCheckPath})
              returnedJsonValue=$(echo ${returnedContent} | jq -r ''${jsonPath}'')
              if [[ ${expectedJsonValue} != "${returnedJsonValue}" ]]; then
                  log_warn "Health check for ${applicationUrl}${urlCheckPath} failed. The returned JSON value \"${returnedJsonValue}\" did not match the expected JSON value \"${expectedJsonValue}\""
              fi
          done
      fi
  done

  # Update hosts file so that a user can use domain names outside of the VM to access the provisioned applications/urls
  updateHostFileForExternalUse

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
