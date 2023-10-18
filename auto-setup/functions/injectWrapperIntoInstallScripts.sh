injectWrapperIntoInstallScripts() {

set +x

local scriptPath="${1}"
local scriptFilename="$(basename ${scriptPath})"
local scriptRelativeSubPath=$(echo "${scriptPath%/*}" | sed 's;'${autoSetupHome}';;g')
local targetScriptDirectoryPath="${installationWorkspace}/auto-setup${scriptRelativeSubPath}"

# Define ansi colours
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[36m"
nc="\033[0m" # No Color

sudo mkdir -p "${targetScriptDirectoryPath}"

log_debug "${blue}Started script wrapper injection for ${scriptPath}${nc}"

export processedScriptFilePath="${targetScriptDirectoryPath}/${scriptFilename}"

# Include Script Header and Footer
export scriptHeaderToInject_Base64=$(echo '''
#!/bin/bash

# Call common function to execute at script start, such as setting verbose output etc
scriptStart
''' | base64)
export scriptFooterToInject_Base64=$(echo '''
# Call common function to execute at script end, such as unsetting verbose output etc
scriptEnd
''' | base64)

originalScript_Base64="$(cat "${scriptPath}" | sed '0,/^#!\/bin\/bash/d' | sed '${/^[[:space:]]*$/d;}' | base64)"

sudo bash -c "cat << 'SCRIPT' | base64 -d > ${processedScriptFilePath}
${scriptHeaderToInject_Base64}
${originalScript_Base64}
${scriptFooterToInject_Base64}
SCRIPT"

if [[ "${scriptFilename}" != "injectWrapperIntoInstallScripts.sh" ]]; then
  sudo sed -i '/####_EXCLUDE_FROM_SCRIPT_HEADER_FOOTER_INJECTION_####/d' ${processedScriptFilePath}
fi

log_debug "${blue}Completed script wrapper injection for ${scriptRelativeSubPath}/${scriptFilename}()${nc}"

if [[ "${logLevel}" == "trace" ]]; then
    set -x
fi

}
