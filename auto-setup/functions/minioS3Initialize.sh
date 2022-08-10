minioS3Initialize() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    if checkApplicationInstalled "minio-operator" "storage"; then

        # Get Mino-S3 access and secret keys
        minioS3GetAccessAndSecretKeys "${baseUser}"

        # Create the S3 Buckets needed for Gitlab in MinIO
        log_debug "mc config host add myminio https://minio-s3.${baseDomain} ${minioAccessKey} ${minioSecretKey} --api S3v4"
        log_debug "$(mc config host add myminio https://minio-s3.${baseDomain} ${minioAccessKey} ${minioSecretKey} --api S3v4)"

    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    
}