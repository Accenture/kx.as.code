# Add box to local Vagrant box library

$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE
$PROVIDER = $PACKER_BUILDER_TYPE -replace "-.*"

$VM_SUFFIX = $env:VM_SUFFIX
$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

vagrant box add ${PACKER_BUILD_NAME} "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json" --force

