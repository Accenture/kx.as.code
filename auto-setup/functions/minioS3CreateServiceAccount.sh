minioS3CreateServiceAccount() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "minio-operator" "storage"; then

        username=${1}

        # Set/Get access and secret keys for user
        minioS3GetAccessAndSecretKeys "${username}"

        # Check if service account already exists for user
        saAccessKey=$(mc admin user svcacct ls myminio/ ${username} --json | jq -r '.accessKey')
        if [[ "${saAccessKey}" == "null" ]] && [[ "${saAccessKey}" != "${minioAccessKey}" ]]; then
            log_debug "$(mc admin user svcacct add --access-key "${minioAccessKey}" --secret-key "${minioSecretKey}" myminio ${username})"
        else
            log_debug "Access key \"${saAccessKey}\" already exists for user ${username}. Skipping"
        fi

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}