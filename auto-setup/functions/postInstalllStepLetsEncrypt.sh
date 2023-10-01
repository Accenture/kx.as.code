postInstallStepLetsEncrypt() {

  if [[ -n ${namespace} ]]; then
    # LetsEncrypt
    letsencryptEnabled=$(cat ${componentMetadataJson} | jq '.letsencrypt?.enabled?')
    letsencryptIngressNames=$(cat ${componentMetadataJson} | jq -r '.letsencrypt?.ingress_names[]?')

    log_debug "letsencryptEnabled: ${letsencryptEnabled}"
    log_debug "letsencryptIngressNames: ${letsencryptIngressNames}"

    # Override Ingress TLS settings if LetsEncrypt is set as issuer
    if [[ "${letsencryptEnabled}" != "false" ]] && [[ "${sslProvider}" == "letsencrypt" ]]; then
      # Get list of ingress resources in namespace
      if [[ -n ${letsencryptIngressNames} ]] && [[ "${letsencryptIngressNames}" != "null" ]]; then
        log_info "Specific ingress name(s) specified in metadata.json for ${componentName} -> ${letsencryptIngressNames}"
      elif [[ "${namespace}" != "kube-system" ]]; then
        log_info "Specific ingress name not specified in metadata.json for ${componentName}. Will look up the ingress names in namespace ${namespace}"
        letsencryptIngressNames=$(kubectl get ingress -n ${namespace} -o json | jq -r '.items[].metadata.name')
      fi

      # Inject LetsEncrypt annotations to the ingress resources
      for ingressName in ${letsencryptIngressNames}; do
        log_info "Adding LetsEncrypt annotations to Ingress --> ${ingressName}"
        kubectl patch ingress ${ingressName} --type='json' -p='[{"op": "add", "path": "/spec/tls/0/secretName", "value":"'${ingressName}'-tls"}]' -n ${namespace}
        kubectl annotate ingress ${ingressName} kubernetes.io/ingress.class=nginx -n ${namespace} --overwrite=true
        kubectl annotate ingress ${ingressName} cert-manager.io/cluster-issuer=letsencrypt-${letsEncryptEnvironment} -n ${namespace} --overwrite=true
      done

    fi
  fi
  
}
