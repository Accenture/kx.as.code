#!/bin/bash
#!/bin/bash -x

# See https://developer.hashicorp.com/vagrant/vagrant-cloud/api/v2

if [ -z "$VAGRANT_CLOUD_TOKEN" ]; then
  echo "Warning: Not uploading to vagrant cloud. Try 'export VAGRANT_CLOUD_TOKEN=...'" >&2
  exit
fi

USER_NAME=kxascode
BOX_NAME=$VM_NAME
VERSION=$VM_VERSION

# PROVIDER_NAME=qemu
PROVIDER_NAME=libvirt
ARCHITECTURE_NAME=arm64

set -euo pipefail

function box_exists() {
  response=$(curl -s \
    --request GET \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME)
  result=$(echo "$response" | jq .name | tr -d \" )
  return $([ "$result" = "$BOX_NAME" ])
}

function create_box() {
  curl \
    --request POST \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/boxes \
    --data "{ \"box\": { \"username\": \"$USER_NAME\", \"name\": \"$BOX_NAME\", \"is_private\": false } }"
}

function version_exists() {
  response=$(curl -s \
    --request GET \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME/version/$VERSION )
  result=$(echo "$response" | jq .version | tr -d \" )
  return $([ "$result" = "$VERSION" ])
}

function create_version() {
  curl \
    --request POST \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME/versions \
    --data "{ \"version\": { \"version\": \"$VERSION\" } }"
}

function provider_exists() {
  response=$(curl -s \
    --request GET \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME/version/$VERSION/provider/$PROVIDER_NAME/$ARCHITECTURE_NAME )
  result=$(echo "$response" | jq .name | tr -d \" )
  return $([ "$result" = "$PROVIDER_NAME" ])
}

function create_provider() {
  curl \
    --request POST \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME/version/$VERSION/providers \
    --data "{ \"provider\": { \"name\": \"$PROVIDER_NAME\", \"architecture\": \"$ARCHITECTURE_NAME\" } }"
}

function get_upload_url() {
  response=$(curl -s \
    --request GET \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME/version/$VERSION/provider/$PROVIDER_NAME/$ARCHITECTURE_NAME/upload)

  # Extract the upload URL from the response (requires the jq command)
  upload_path=$(echo "$response" | jq .upload_path | tr -d \" )
  echo $upload_path
}

box_exists || create_box
version_exists || create_version
provider_exists || create_provider

upload_url=$(get_upload_url)

# Perform the upload
echo "Uploading to $upload_url ..."
# curl -s --request PUT "${upload_url}" --upload-file ../../../boxes/$PROVIDER_NAME-$VERSION/$BOX_NAME-$VERSION.box
curl -s --request PUT "${upload_url}" --upload-file ../../../boxes/qemu-$VERSION/$BOX_NAME-$VERSION.box
echo "Upload done."

exit

# Release the version
curl \
  --request PUT \
  https://app.vagrantup.com/api/v2/box/$USER_NAME/$BOX_NAME/version/$VERSION/release?access_token=$ACCESS_TOKEN
