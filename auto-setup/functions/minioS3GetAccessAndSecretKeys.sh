minioS3GetAccessAndSecretKeys() {

    username=${1}

    # Get MinIO Access Access and Secret Keys
    export minioAccessKey=$(managedApiKey "minio-s3-${username}-sa-access-key")
    export minioSecretKey=$(managedApiKey "minio-s3-${username}-sa-secret-key")
    
}