sourceKeycloakEnvironment() {

  # Set Keycloak variables for subsequent calls to Keycloak
  export kcRealm="${baseDomain}"
  export kcInternalUrl="http://localhost:8080"
  export kcAdmCli="/opt/jboss/keycloak/bin/kcadm.sh"
  if checkApplicationInstalled "keycloak" "core"; then
    export kcPod="$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')"
  fi
  export kcContainer="keycloak"
  export kcNamespace="keycloak"
  export kcBinDir="/opt/jboss/keycloak/bin/"
  export keycloakAdminPassword=$(managedPassword "keycloak-admin-password" "keycloak")
  if which slapcat >/dev/null; then
    export ldapDn=$(/usr/bin/sudo slapcat | grep dn | head -1 | cut -f2 -d' ')
  fi

}
