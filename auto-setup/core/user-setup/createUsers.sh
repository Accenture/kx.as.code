#!/bin/bash

if [[ "${vmUser}" != "${baseUser}" ]] && [[ -f ${installationWorkspace}/users.json ]]; then
  # Check if owner details defined in users.json
  firstname=$(jq -r '.config.owner.firstname' ${installationWorkspace}/users.json)
  surname=$(jq -r '.config.owner.surname' ${installationWorkspace}/users.json)
  email=$(jq -r '.config.owner.email' ${installationWorkspace}/users.json)
  defaultUserKeyboardLanguage=$(jq -r '.config.owner.keyboard_language' ${installationWorkspace}/users.json)
  userRole=$(jq -r '.config.owner.role' ${installationWorkspace}/users.json)
else
  # Check if owner details defined in users.json
  firstname="Kx"
  surname="Hero"
  email="kx.hero@${baseDomain}"
  defaultUserKeyboardLanguage="us"
  userRole="admin"
fi

# Create base user in LDAP and provide access to remote desktop services
createUsers "${firstname}" \
            "${surname}" \
            "${email}" \
            "${defaultUserKeyboardLanguage}" \
            "${userRole}"

if [[ -f ${installationWorkspace}/users.json ]]; then
  # Call function for creating users
  # Note: Feature externalized to function so it can be called separately outside of the framework using the manual execution wrapper
  createUsers
fi