addOauthProxyToComponentNamespace() {

  local ingressName=${1:-"${componentName}-ingress"}
  local ingressNamespace=${2:-"${namespace}"}
  local ingresServiceName=${3:-"${componentName}"}
  local separateExternalAccess=${4:-"true"} # if true, will restrict access of original domain to local domain only and create a new FQDN (with -ext) for remote access via OAUTH only. 
  # If separateExternalAccess=false, then Keycloak OAUTH will be triggered on original domain even when accessed locally inside VM

  if [[ "${separateExternalAccess}" == "true" ]]; then
    externalDomain="${ingresServiceName}-ext.${baseDomain}"
  else
    externalDomain="${ingresServiceName}.${baseDomain}"
  fi

  if checkApplicationInstalled "keycloak" "core"; then

    # Integrate solution with Keycloak
    redirectUris="https://${externalDomain}/oauth2/callback"
    rootUrl="https://${externalDomain}"
    baseUrl="/oauth2/callback"
    protocol="openid-connect"
    fullPath="true"
    scopes="groups" # space separated if multiple scopes need to be created/associated with the client
    log_debug "FUNCTION_CALL: enableKeycloakSSOForSolution \"${redirectUris}\" \"${rootUrl}\" \"${baseUrl}\" \"${protocol}\" \"${fullPath}\" \"${scopes}\" \"${ingressNamespace}\""
    enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}" "${ingressNamespace}"

    # Set variables for oauth-proxy
    #cookieSecret=$(managedApiKey "oauth-proxy-token" "keycloak")
    export cookieSecret=$(docker run --rm python:3 python -c 'import os,base64; print(base64.b64encode(os.urandom(16)).decode("ascii"))')

    # Create CA config map for connecting to Kubernetes Dashboard from Oauth2-Proxy
    echo """kind: ConfigMap
  apiVersion: v1
  metadata:
    name: ${ingressNamespace}-ca-certificate
    namespace: ${ingressNamespace}
  data:
    ca.crt: |-
      $(/usr/bin/sudo cat ${installationWorkspace}/kx-certs/ca.crt | sed '2,30s/^/      /')
  """ | sed 's/^  //g' | /usr/bin/sudo tee ${installationWorkspace}/${ingressNamespace}-ca-configmap.yaml
    kubernetesApplyYamlFile "${installationWorkspace}/${ingressNamespace}-ca-configmap.yaml" "${ingressNamespace}"

    # Deploy oauth-proxy
    echo '''apiVersion: apps/v1
  kind: Deployment
  metadata:
    labels:
      k8s-app: oauth2-proxy
    name: oauth2-proxy
    namespace: '${ingressNamespace}'
  spec:
    replicas: 1
    selector:
      matchLabels:
        k8s-app: oauth2-proxy
    template:
      metadata:
        labels:
          k8s-app: oauth2-proxy
      spec:
        containers:
        - args:
            - --provider=oidc
            - --provider-display-name="'${baseDomain}'"
            - --client-id='${ingressNamespace}'
            - --client-secret='${clientSecret}'
            - --cookie-secret='${cookieSecret}'
            - --cookie-domain=.{{baseDomain}}
            - --redirect-url=/oauth2/callback
            - --oidc-issuer-url=https://keycloak.'${baseDomain}'/auth/realms/'${baseDomain}'
            - --provider-ca-file=/etc/ssl/'${ingressNamespace}'-ca-certificate/ca.crt
            - --reverse-proxy=true
            - --set-authorization-header=true
            - --http-address=0.0.0.0:4180
            - --email-domain=*
            - --oidc-groups-claim=groups
            - --user-id-claim=sub
          env:
            - name: OAUTH2_PROXY_CLIENT_ID
              value: '${ingressNamespace}'
            - name: OAUTH2_PROXY_CLIENT_SECRET
              value: '${clientSecret}'
            - name: OAUTH2_PROXY_COOKIE_SECRET
              value: '${cookieSecret}'
          image: quay.io/pusher/oauth2_proxy:latest
          imagePullPolicy: Always
          name: oauth2-proxy
          ports:
          - containerPort: 4180
            protocol: TCP
          volumeMounts:
          - name: '${ingressNamespace}'-ca-certificate
            mountPath: /etc/ssl/'${ingressNamespace}'-ca-certificate
        volumes:
        - name: '${ingressNamespace}'-ca-certificate
          configMap:
            name: '${ingressNamespace}'-ca-certificate
  ''' | sed 's/^  //g' | /usr/bin/sudo tee "${installationWorkspace}/${ingressName}-oauth2-proxy-deployment.yaml"
    kubernetesApplyYamlFile "${installationWorkspace}/${ingressName}-oauth2-proxy-deployment.yaml" "${ingressNamespace}"

    # Deploy oauth-proxy
    echo '''apiVersion: v1
  kind: Service
  metadata:
    labels:
      k8s-app: oauth2-proxy
    name: oauth2-proxy
    namespace: '${ingressNamespace}'
  spec:
    ports:
    - name: http
      port: 4180
      protocol: TCP
      targetPort: 4180
    selector:
      k8s-app: oauth2-proxy
  ''' | sed 's/^  //g' | /usr/bin/sudo tee "${installationWorkspace}/${ingressName}-oauth2-proxy-service.yaml"
    kubernetesApplyYamlFile "${installationWorkspace}/${ingressName}-oauth2-proxy-service.yaml" "${ingressNamespace}"

    # Export YAML object and add annotations
    kubernetesExportCleanResourceYaml "${ingressName}" "ingress" "${ingressNamespace}"
    local exportedYamlFilename=${installationWorkspace}/${ingressName}-ingress-${ingressNamespace}_export.yaml

    if [[ "${separateExternalAccess}" == "true" ]]; then
      # Add new ingress resource for external access (original domain with -ext added) with Keycloak MFA.
      # Change URls and resource name to avoid overriding original resource
      yq -i '.spec.rules[0].host="'${componentName}'-ext.'${baseDomain}'"' ${exportedYamlFilename} --yaml-output
      yq -i '.spec.tls[0].hosts[0]="'${componentName}'-ext.'${baseDomain}'"' ${exportedYamlFilename} --yaml-output
      yq -i '.metadata.name="'${componentName}'-ext-oauth-ingress"' ${exportedYamlFilename} --yaml-output
    fi

    # Add OAUTH annotations to existing ingress object
    yq -i ".metadata.annotations += ({\"nginx.ingress.kubernetes.io/auth-url\": \"https://\$host/oauth2/auth\"})" ${exportedYamlFilename} --yaml-output
    yq -i ".metadata.annotations += ({\"nginx.ingress.kubernetes.io/auth-signin\": \"https://\$host/oauth2/start?rd=\$escaped_request_uri\"})" ${exportedYamlFilename} --yaml-output
    yq -i ".metadata.annotations += ({\"nginx.ingress.kubernetes.io/auth-response-headers\": \"authorization\"})" ${exportedYamlFilename} --yaml-output

    if [[ "${separateExternalAccess}" == "true" ]]; then
      # Remove whitelist from exported resource definition in case this script was re-run
      yq -i "del(.metadata.annotations.\"nginx.ingress.kubernetes.io/whitelist-source-range\")" ${exportedYamlFilename} --yaml-output
    fi
    # Apply YAML ingress file for proected external access
    kubernetesApplyYamlFile "${exportedYamlFilename}"

    if [[ "${separateExternalAccess}" == "true" ]]; then
      # Get local subnet for whitelisting
      allowIpRangeForOauthLessAccess="$(echo ${mainIpAddress} | cut -d"." -f1-3).0/24"
      # Add IP CIDR to NGINX allowlist to original ingress resource
      kubectl annotate --overwrite ingress ${ingressName} -n ${ingressNamespace} "nginx.ingress.kubernetes.io/whitelist-source-range=${allowIpRangeForOauthLessAccess}"
    fi

    # Add OAUTH ingress object for component
    echo '''apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: '${ingresServiceName}'-oauth2-proxy
    namespace: '${ingressNamespace}'
    annotations:
      nginx.ingress.kubernetes.io/proxy-buffer-size: 16k
  spec:
    ingressClassName: nginx
    rules:
    - host: '${externalDomain}'
      http:
        paths:
        - backend:
            service:
              name: oauth2-proxy
              port:
                number: 4180
          path: /oauth2
          pathType: Prefix
    tls:
    - hosts:
      - '${externalDomain}'
  ''' | sed 's/^  //g' | /usr/bin/sudo tee ${installationWorkspace}/${ingresServiceName}-oauth2-proxy-ingress.yaml
    kubernetesApplyYamlFile "${installationWorkspace}/${ingresServiceName}-oauth2-proxy-ingress.yaml" "${ingressNamespace}"
  fi

}
