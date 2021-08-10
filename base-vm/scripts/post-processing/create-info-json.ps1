
$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE

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

if ( -not ( Test-Path -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}" ) )
{
    New-Item -ItemType Directory -Force "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}"
}

if ( Test-Path -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json" -PathType Leaf )
{
    if ( Test-Path -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json.previous" -PathType Leaf )
    {
        Remove-Item -Force -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json.previous"
    }
    Rename-Item -Force -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json" -NewName "info.json.previous"
}

Copy-Item -Force -Path "..\..\..\templates\info.template" -Destination "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json"
(Get-Content "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json").replace('##USERNAME##', 'Accenture Interactive') | Set-Content "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\info.json"
