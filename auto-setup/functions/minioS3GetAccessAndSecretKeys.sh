minioS3GetAccessAndSecretKeys() {

    # Get MinIO Access Access and Secret Keys
    export minioAccessKey=$(managedApiKey "minio-s3-access-key")
    export minioSecretKey=$(managedApiKey "minio-s3-secret-key")
    
}