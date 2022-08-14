# IAM and SSO

Identity Access Management (IAM) and Single Sign On (SSO) are managed by [KeyCloak](https://www.keycloak.org/){:target="\_blank"} in KX.AS.CODE. 

The backend for Keycloak is OpenLDAP. When a user is added to `users.json` ([example](https://github.com/Accenture/kx.as.code/blob/main/profiles/vagrant-virtualbox/users.json){:target="\_blank"}), the user is automatically provisioned in OpenLDAP.
`users.json` is read by [createUser.sh](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/core/user-setup/createUsers.sh){:target="\_blank"}, which provisions the users in OpenLDAP.

The core scripts for setting up OpenLDAP and Keycloak are at the following locations:

* [Keycloak](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/keycloak){:target="\_blank"}
* [OpenLDAP](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/openldap){:target="\_blank"}

Keycloak does a regular sync with OpenLDAP, so once created, the user will shortly be available in Keycloak, and therefore also have access to all the applications that have Keycloak configured as their external OAUTH provider.

In most cases, applications can be configured in Keycloak with a single call to [enableKeycloakSSOForSolution()](../../Development/Available-Functions/#enablekeycloakssoforsolution).

See [here](../../Development/Available-Functions/#keycloak-iamsso) for all [Keycloak functions](../../Development/Available-Functions/#keycloak-iamsso) available when developing to add a new application to KX.AS.CODE.


