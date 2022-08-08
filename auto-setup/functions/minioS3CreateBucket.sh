minioS3CreateBucket() {

    bucketName=${1}
    tenant=${2-myminio}
    region=${3-eu-central-1}

    # Create S3 Bucket if it doesn't already exist
    if [[ -z $(mc ls ${tenant}/${bucketName} --json | jq -r '.status?') ]]; then
        mc mb ${tenant}/${bucketName} --region ${region} --ignore-existing
    fi

}