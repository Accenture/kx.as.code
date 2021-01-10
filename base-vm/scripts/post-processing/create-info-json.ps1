
$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE
$PROVIDER = $PACKER_BUILDER_TYPE -replace "-.*"

$VM_SUFFIX = $env:VM_SUFFIX
$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

if ( -not ( Test-Path -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}" ) )
{
    New-Item -ItemType Directory -Force "..\..\..\boxes\${PROVIDER}-${VM_VERSION}"
}

if ( Test-Path -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json" -PathType Leaf )
{
    if ( Test-Path -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json.previous" -PathType Leaf )
    {
        Remove-Item -Force -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json.previous"
    }
    Rename-Item -Force -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json" -NewName "info.json.previous"
}

Copy-Item -Force -Path "..\..\..\templates\info.template" -Destination "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json"
(Get-Content "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json").replace('##USERNAME##', 'Accenture Interactive') | Set-Content "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\info.json"

