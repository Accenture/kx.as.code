$PACKER_BUILD_NAME = $env:PACKER_BUILD_NAME
$PACKER_BUILDER_TYPE = $env:PACKER_BUILDER_TYPE

$VM_SUFFIX = $env:VM_SUFFIX
$VM_NAME = $env:VM_NAME
$VM_VERSION = $env:VM_VERSION

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

if ( $VM_NAME.Contains("main") )
{
    $KX_VM_TYPE = "main"
}

if ( $VM_NAME.Contains("node") )
{
    $KX_VM_TYPE = "node"
}

Write-Output "ovftool --diskMode=thin --compress=9 --name=${VM_NAME}-${VM_VERSION} --prop:vendor=`"KX.AS.CODE`" --prop:vendorUrl=`"https://github.com/Accenture/kx.as.code`" --prop:product=`"KX.AS.CODE`" --prop:productUrl=`"https://github.com/Accenture/kx.as.code`" --prop:version=`"${VM_VERSION}`" --prop:fullVersion=`"${VM_VERSION}`" --annotation=`"OVA version of KX.AS.CODE VMWare Image`" `"../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.vmx `"../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.ova"

# Create VMWare OVA file
ovftool --diskMode=thin --compress=9 --name="${VM_NAME}-${VM_VERSION}" --prop:vendor="KX.AS.CODE" --prop:vendorUrl="https://github.com/Accenture/kx.as.code" --prop:product="KX.AS.CODE" --prop:productUrl="https://github.com/Accenture/kx.as.code" --prop:version="${VM_VERSION}" --prop:fullVersion="${VM_VERSION}" --annotation="OVA version of KX.AS.CODE VMWare Image" "../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.vmx" "../../../output-${KX_VM_TYPE}/${OUTPUT_DIR}-${VM_VERSION}/${VM_NAME}-${VM_VERSION}.ova"
