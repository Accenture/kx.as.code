minioS3Initialize() {

    # Get Mino-S3 access and secret keys
    minioS3GetAccessAndSecretKeys

    # Create the S3 Buckets needed for Gitlab in MinIO
    mc config host add minio https://minio-s3.${baseDomain} ${minioAccessKey} ${minioSecretKey} --api S3v4
    log_debug "mc config host add minio https://minio-s3.${baseDomain} ${minioAccessKey} ${minioSecretKey} --api S3v4"

}