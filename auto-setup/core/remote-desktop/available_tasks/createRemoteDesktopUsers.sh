#!/bin/bash

# Get list of users to add to Guacamole database by merging owner and additional user array
usersToCreate=$(cat ${installationWorkspace}/users.json | jq -r '[ .config.owner, .config.additionalUsers[] ]')

# Get number of users in merged array
numUsersToCreate=$(echo ${usersToCreate} | jq -r '.[].firstname' | wc -l)

for i in $(seq 0 $((numUsersToCreate - 1))); do

    firstname=$(echo ${usersToCreate} | jq -r '.['$i'].firstname')
    surname=$(echo ${usersToCreate} | jq -r '.['$i'].surname')
    email=$(echo ${usersToCreate} | jq -r '.['$i'].email')
    defaultUserKeyboardLanguage=$(echo ${usersToCreate} | jq -r '.['$i'].keyboard_language')
    userRole=$(echo ${usersToCreate} | jq -r '.['$i'].role')

    # Generate user id
    if [[ "${firstname}" == "Kx" ]] ;then
      userid="kx.hero"
    else
      userid=$(generateUsername "${firstname}" "${surname}")
    fi

    echo "${userid} ${firstname} ${surname} ${email} ${userRole}"

    # Create Guacamole user
    guacamoleCreateDbUser "${userid}"

    # Assign Guacamole user permissions for self administration
    guacamoleAssignUserPermissions "${userid}"

    # Assign Guacamole XRDP connection
    guacamoleAssignUserXrpConnection "${userid}"

    # Assign Guacamole system administration rights
    if [[ "${userRole}" == "admin" ]]; then
      guacamoleAssignAdminPermissions "${userid}"
    fi

done

