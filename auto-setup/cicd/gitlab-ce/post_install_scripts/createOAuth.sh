#!/bin/bash -x

export kcRealm=${baseDomain}
export kcInternalUrl=http://localhost:8080
export kcAdmCli=/opt/jboss/keycloak/bin/kcadm.sh
export kcPod=$(kubectl get pods -l 'app.kubernetes.io/name=keycloak' -n keycloak --output=json | jq -r '.items[].metadata.name')
export kcContainer="keycloak"

# Set credential token in new Realm
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} config credentials --server ${kcInternalUrl}/auth --realm ${kcRealm} --user admin --password ${vmPassword}

## Create client
kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} create clients --realm ${kcRealm} -s clientId=${componentName} \
    -s 'redirectUris=["https://'${componentName}'.'${baseDomain}'/auth/callback"]' \
    -s publicClient="false" -s enabled=true -s rootUrl="https://${componentName}.${baseDomain}" -s baseUrl="/applications" -i

## export clientId
export clientId=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients --fields id,clientId | jq -r '.[] | select(.clientId=="gitlab-ce") | .id')

# Get client secret
clientSecret=$(kubectl -n keycloak exec ${kcPod} --container ${kcContainer} -- \
    ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')

# If secret not available, generate a new one
if [[ "${clientSecret}" == "null" ]]; then
  kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} create clients/${clientId}/client-secret | jq -r '.value'
  clientSecret=$(kubectl -n keycloak exec ${kcPod} -- \
      ${kcAdmCli} get clients/${clientId}/client-secret | jq -r '.value')
fi

################### kubernetes manifests CRUD operations #####################################

kubectl get cm gitlab-ce-webservice -n gitlab-ce -o json > cm.json

# This is a ugly hack which should be improvised if a better is found. From the cm.json file we will perform some file modifications
# by removing gitlab.yml.erb section first where the sso keycloak config goes. Now we have another file called oAuthSupport
# which has this config already but with dummy values, those dummy value will be replaced with actual values and remove gitlab.yml.erb line
# will be added again into cm.json and applied with kubectl

/usr/bin/sudo sed -i '/gitlab.yml.erb/d' cm.json
/usr/bin/sudo sed -ie "s/DummyIssuer/${baseDomain}/g" oAuthSupport.json
/usr/bin/sudo sed -ie "s/DummyRealm/${baseDomain}/g" oAuthSupport.json
/usr/bin/sudo sed -ie "s/DummySecret/${clientSecret}/g" oAuthSupport.json
/usr/bin/sudo sed -ie "s/DummyRedirectUri/${componentName}.${baseDomain}/g" oAuthSupport.json
/usr/bin/sudo sed -ie "s/DummyIdentifier/${componentName}/g" oAuthSupport.json
/usr/bin/sudo sed -i '/installation_type/r oAuthSupport.json' cm.json

kubectl apply -f cm.json


