
$PACKER_BUILD_NAME = $env:PACKER_BUILD_NAME
$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE
$PROVIDER = $PACKER_BUILDER_TYPE -replace "-.*"

$VM_SUFFIX = $env:VM_SUFFIX
$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

# Generate SHA512 for box
$CHECKSUM=(get-filehash -Algorithm SHA512 "../../../boxes/${PROVIDER}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box").Hash

if ( -not ( Test-Path -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}" ) )
{
    New-Item -ItemType Directory -Force "..\..\..\boxes\${PROVIDER}-${VM_VERSION}"
}

if ( Test-Path -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json" -PathType Leaf )
{
    if ( Test-Path -Path "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous" -PathType Leaf )
    {
        Remove-Item -Force "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous"
    }
    Rename-Item -Force "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json" -NewName "${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json.previous"
}

Copy-Item -Force "..\..\..\templates\metadata.template" -Destination "..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json"

(Get-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##NAME##", "${PACKER_BUILD_NAME}") | Set-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##DESCRIPTION##", "Accenture Interactive KX.AS.CODE DevOps VM - PLAY LEARN INNOVATE") | Set-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##VERSION##", "${VM_VERSION}") | Set-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##PROVIDER##", "${PROVIDER}") | Set-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##URL##", "../../../boxes/${PROVIDER}-${VM_VERSION}/${VM_NAME}${VM_SUFFIX}-${VM_VERSION}.box") | Set-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json
(Get-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json).replace("##CHECKSUM##", "${CHECKSUM}") | Set-Content ..\..\..\boxes\${PROVIDER}-${VM_VERSION}\${VM_NAME}${VM_SUFFIX}-${VM_VERSION}_metadata.json



