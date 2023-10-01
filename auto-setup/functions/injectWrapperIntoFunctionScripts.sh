injectWrapperIntoFunctionScripts() {

local functionsLocation="${1}"

# Define ansi colours
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[36m"
nc="\033[0m" # No Color

export scriptFooterToInject_Base64=$(echo '''
# Only execute if this function is being executed, rather than the script being sourced during the framework intitialization
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # This function is being executed.
    __action__="__direct_script_execution__"
else
    # This script is being sourced.
    __action__="__sourced__"
fi

# Only execute the function if it is being executed rather than the script being sourced
if [ "$__action__" = "__direct_script_execution__" ]; then
    echo "Script containing function ${BASH_SOURCE[0]} was executed directly. Warning, function will likely not work outside of the framework, as it needs input parameters, and was not designed to work wihout them!"
    basename "${0}" ".sh"  # Script name must be the same as the function name for this to work
else
    echo "Script ${BASH_SOURCE[0]} was sourced. Not executing function"
fi
''' | base64)

baseFunctionsDirectory=$(basename ${functionsLocation})
processedFunctionsLocation="${installationWorkspace}/${baseFunctionsDirectory}"
sudo mkdir -p ${processedFunctionsLocation}
for function in $(find ${functionsLocation} -name "*.sh")
do
  log_debug "${blue}Started script creation for ${function}${nc}"
  functionName="$(grep -E -o -m 1 '^[[:alnum:]].*().*{$' "${function}" | sed 's/()*.{//g' | tr -d ' \t\n\r')"
  functionName_Base64="$(echo -n "${functionName}" | base64)"
  if [[ -z ${functionName} ]]; then
    log_debug "${red}Function name for \"${function}\" could not be established${nc}"
  fi
  processedFunctionFilePath="${processedFunctionsLocation}/${functionName}.sh"

  if cat ${function} | head -1 | grep "####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####"; then
    # Exclude Function Header and Footer
    export functionHeaderToInject_Base64=""
    export functionFooterToInject_Base64=""
  else
    # Include Function Header and Footer
    export functionHeaderToInject_Base64=$(echo '''
    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart
    ''' | base64)
    export functionFooterToInject_Base64=$(echo '''
    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd
    ''' | base64)
  fi

  originalFunction_Base64="$(cat "${function}" | sed '0,/^[[:alnum:]].*().*{/s///' | sed '1h;1!H;$!d;g;s/\(.*\)}/\1/' | sed '${/^[[:space:]]*$/d;}' | base64)"

sudo bash -c "cat << 'FUNCTION' | base64 -d > ${processedFunctionFilePath}
${functionName_Base64}$(echo "() {" | base64)
${functionHeaderToInject_Base64}
${originalFunction_Base64}
${functionFooterToInject_Base64}
$(echo "}" | base64)

${scriptFooterToInject_Base64}
FUNCTION"

if [[ "${functionName}" != "injectWrapperIntoFunctionScripts" ]]; then
  sudo sed -i '/####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####/d' ${processedFunctionFilePath}
fi

log_debug "${blue}Completed script creation for ${functionName}()${nc}"
source ${processedFunctionFilePath}

if type "${functionName}" 2>/dev/null | grep -q 'function'; then
  log_debug "${green}Loaded function ${functionName}() successfully${nc}"
else
  log_debug "${red}Function ${functionName}() did not load successfully. Check function for errors and try again${nc}"
fi

done

}
