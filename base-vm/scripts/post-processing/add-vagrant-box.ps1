# Add box to local Vagrant box library

$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE
$PROVIDER = $PACKER_BUILDER_TYPE -replace "-.*"

if (${PACKER_BUILDER_TYPE} -eq "vmware-iso")
{
    $OUTPUT_DIR = "vmware-desktop"
}

if (${PACKER_BUILDER_TYPE} -eq "parallels-iso")
{
    $OUTPUT_DIR = "parallels"
}

if (${PACKER_BUILDER_TYPE} -eq "virtualbox-iso")
{
    $OUTPUT_DIR = "virtualbox"
}

$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

vagrant box add kxascode/${PACKER_BUILD_NAME} "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}-${VM_VERSION}_metadata.json" --force
