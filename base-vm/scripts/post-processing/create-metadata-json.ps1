
$PACKER_BUILD_NAME = $env:PACKER_BUILD_NAME
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

$PROVIDER = $OUTPUT_DIR.replace("-","_")

$VM_SUFFIX = $env:VM_SUFFIX
$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

# Generate SHA512 for box
$CHECKSUM=(get-filehash -Algorithm SHA512 "../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box").Hash

if ( -not ( Test-Path -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}" ) )
{
    New-Item -ItemType Directory -Force "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}"
}

if ( Test-Path -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json" -PathType Leaf )
{
    if ( Test-Path -Path "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous" -PathType Leaf )
    {
        Remove-Item -Force "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous"
    }
    Rename-Item -Force "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json" -NewName "${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous"
}

Copy-Item -Force "..\..\..\templates\metadata.template" -Destination "..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json"

(Get-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##NAME##", "${PACKER_BUILD_NAME}") | Set-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##DESCRIPTION##", "Accenture Interactive KX.AS.CODE DevOps VM - PLAY LEARN INNOVATE") | Set-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##VERSION##", "${VM_VERSION}") | Set-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##PROVIDER##", "${PROVIDER}") | Set-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##URL##", "../../../boxes/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box") | Set-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##CHECKSUM##", "${CHECKSUM}") | Set-Content ..\..\..\boxes\${OUTPUT_DIR}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
