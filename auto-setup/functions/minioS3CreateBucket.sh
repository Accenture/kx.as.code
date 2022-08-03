minioS3CreateBucket() {

    minioS3BucketName=${1}

    # Create S3 Bucket if it doesn't already exist
    minioS3BucketExists=$(mc ls  myminio --insecure --json | jq '. | select(.key=="'${minioS3BucketName}'/")')
    if [[ -z ${minioS3BucketExists} ]]; then
        mc mb myminio/${minioS3BucketName} --insecure
    fi

}