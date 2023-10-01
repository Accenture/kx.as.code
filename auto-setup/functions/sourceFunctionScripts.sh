sourceFunctionScripts() {

  local functionsLocation="${1}"

  # Define ansi colours
  red="\033[31m"
  green="\033[32m"
  orange="\033[33m"
  blue="\033[36m"
  nc="\033[0m" # No Color

  for function in $(find ${functionsLocation} -name "*.sh")
  do

    source ${function}
    functionName="$(grep -E -o -m 1 '^[[:alnum:]].*().*{$' "${function}" | sed 's/()*.{//g' | tr -d ' \t\n\r')"

    if type "${functionName}" 2>/dev/null | grep -q 'function'; then
      log_debug "${green}Loaded function ${functionName}() successfully${nc}"
    else
      log_debug "${red}Function ${functionName}() did not load successfully. Check function for errors and try again${nc}"
    fi

  done

}
