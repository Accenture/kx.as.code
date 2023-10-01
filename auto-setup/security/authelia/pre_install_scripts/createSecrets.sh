#!/bin/bash -x

# Create passwords, tokens, keys for Authelia secret creation
export autheliaJwtToken=$(managedApiKey "jwt-token" "authelia")
export ldapAdminPassword=$(getPassword "openldap-admin-password" "openldap")
export autheliaStoragePassword=$(managedPassword "mariadb-authelia-password" "authelia")
export autheliaStorageEncryptionKey=$(managedApiKey "storage-encryption-key" "authelia")
export autheliaSmtpUsername=$(getPassword "smtp_username" "base-technical-credentials")
export autheliaSmtpPassword=$(getPassword "smtp_password" "base-technical-credentials")

# Create secret for Authelia if it does not exist
#kubectl get secret authelia --namespace ${namespace} ||
#    kubectl create secret generic authelia \
#        --from-literal=JWT_TOKEN=${autheliaJwtToken} \
#        --from-literal=LDAP_PASSWORD=${ldapAdminPassword} \
#        --from-literal=STORAGE_PASSWORD=${autheliaStoragePassword} \
#        --from-literal=STORAGE_ENCRYPTION_KEY=${autheliaStorageEnvryptionKey} \
#        --from-literal=SESSION_ENCRYPTION_KEY=${autheliaSessionEncryptionKey} \
#        --namespace ${namespace}

# Add needed labels or Helm chart fails to deploy
#kubectl label secret authelia "app.kubernetes.io/managed-by=Helm" --namespace ${namespace}
#kubectl label secret authelia "meta.helm.sh/release-name=authelia" --namespace ${namespace}
#kubectl label secret authelia "meta.helm.sh/release-namespace=authelia" --namespace ${namespace}
