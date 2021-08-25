
$PACKER_BUILD_NAME = $env:PACKER_BUILD_NAME
$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE
$PROVIDER = $PACKER_BUILDER_TYPE -replace "-.*"

$VM_SUFFIX = $env:VM_SUFFIX
$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

if ( $VM_NAME.Contains("main") )
{
    $KX_VM_TYPE = "main"
}

if ( $VM_NAME.Contains("node") )
{
    $KX_VM_TYPE = "node"
}

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

if ( Test-Path -Path "..\..\..\output-${KX_VM_TYPE}${VM_SUFFIX}\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json" -PathType Leaf )
{
    if ( Test-Path -Path "..\..\..\output-${KX_VM_TYPE}${VM_SUFFIX}\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json.previous" -PathType Leaf )
    {
        Remove-Item -Force -Path "..\..\..\output-${KX_VM_TYPE}${VM_SUFFIX}\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json.previous"
    }
    Rename-Item -Force -Path "..\..\..\output-${KX_VM_TYPE}${VM_SUFFIX}\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json" -NewName "${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json.previous"
}

if ( Test-Path -Path "${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json" -PathType Leaf )
{
    Write-Output "Move-Item -Force -Path ${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json -Destination ..\..\..\output-${KX_VM_TYPE}${VM_SUFFIX}\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json"
    Move-Item -Force -Path "${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json" -Destination "..\..\..\output-${KX_VM_TYPE}${VM_SUFFIX}\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_manifest.json"
}
