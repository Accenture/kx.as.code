#!/bin/bash

logLevel="info"

# Check if underlying system is Mac or Linux
system=$(uname)

# Executable paths if required
if [[ "${system}" == "Darwin" ]]; then
# Mac
  opensslVersionRequired="3.0.5"
elif [[ "${system}" == "Linux" ]]; then
# Linux
  opensslVersionRequired="1.1.1"
fi

# Define ansi colours
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[36m"
nc="\033[0m" # No Color


checkExecutableExists() {
  local executableToCheck="${1}"
  local warnOrErrorIfNotExist="${2}"

  # Define path to executable
  if [[ "${executableToCheck:0:1}" != / && "${executableToCheck:0:2}" != ~[/a-z] ]]; then
    executablePath=$(which "${executableToCheck}")
  else
    executablePath=${executableToCheck}
  fi

  if [[ ! -f ${executablePath} ]]; then
    log_"${warnOrErrorIfNotExist}" "Executable ${executableToCheck} does not exist at the given path."
    if [[ "${warnOrErrorIfNotExist}" == "error" ]]; then
     ((checkErrors++))
      return 1
    else
      return 2
    fi
  else
    # Check if binary is executable
    if [[ -x "${executablePath}" ]]; then
      log_info "Executable ${executablePath} exists and is executable. Continuing with version check."
      return 0
    else
      log_error "Executable ${executablePath} exists, but is not executable. Will exit with non-zero return code."
      ((checkErrors++))
      return 1
    fi
  fi

}

checkOpenSSLVersion() {
  checkExecutableExists "openssl" "error"
  checkResponse=$?
  if [[ "${checkResponse}" -eq 0 ]]; then
    installedOpenSslVersion=$(openssl version | grep -E -o "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)" | head -1)
    versionCompare "${installedOpenSslVersion}" "${opensslVersionRequired}" "OpenSSL"
    if [[ "$?" == "1" ]] && [[ "${system}" == "Darwin" ]]; then
        log_error "Unfortunately Mac has an outdated OpenSSL library. Suggested resolution is to upgrade with Homebrew -> brew install openssl@3"
        log_error "Although for Linux and Windows 1.1.1 is fine, for Mac the @3 part is important"
    fi
  fi
}

versionCompare() {
  local currentVersion=${1}
  local expectedVersion=${2}
  local executable=${3}

  if [[ "${currentVersion}" > "${expectedVersion}" ]] || [[ "${currentVersion}" == "${expectedVersion}" ]]; then
    log_info "Installed \"${executable}\" version is \"${currentVersion}\", which is equal to or greater than the expected \"${expectedVersion}\""
    return 0
  else
    log_warn "Installed \"${executable}\" version is \"${currentVersion}\", which is less than the expected \"${expectedVersion}\". Whilst this may work, in some cases this may result in compatibility issues!"
    ((checkWarnings++))
    return 1
  fi
}

checkVersions()  {

  # Set warnings and error count
  checkWarnings=0
  checkErrors=0

  checkOpenSSLVersion
  log_debug "checkErrors: ${checkErrors}"
  log_debug "Errors: ${checkErrors}"
  log_debug "Warnings: ${checkWarnings}"

  if [[ "${checkErrors}" -gt 0 ]]; then
    log_error "There were errors during dependency checks. Please resolve these issues and relaunch the script."
    exit 1
  elif [[ "${checkWarnings}" -gt 0 ]] && [[ "${1}" != "-i" ]]; then
    log_warn "There was/were ${checkWarnings} warning(s) during the dependency version checks. You can choose to ignore these by starting the script with the -i option."
    log_warn "Be aware that old versions of dependencies may result in the solution not working correctly."
    exit 1
  elif [[ "${checkWarnings}" -gt 0 ]] && [[ "${1}" == "-i" ]]; then
    log_warn "There was/were ${checkWarnings} warning(s) during the dependency version checks. Will continue anyway, as you started this script with the -i option."
    log_warn "Be aware that old versions of dependencies may result in the solution not working correctly."
  fi

}

log_debug() {
    if [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "[DEBUG] ${1}${nc}"
    fi
}

log_error() {
    if [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "${red}[ERROR] ${1}${nc}"
    fi
}

log_info() {
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "[INFO] ${1}${nc}"
    fi
}

log_trace() {
    if [[ "${logLevel}" == "trace" ]]; then
        >&2 echo -e "[TRACE] ${1}${nc}"
    fi
}

log_warn() {
    if [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "${orange}[WARN] ${1}${nc}"
    fi
}

override_action=""
error=""

# Source the user configured env file before creating the KX.AS.CODE Jenkins environment
if [ ! -f ./jenkins.env ]; then
  log_error "Please create the jenkins.env file in the base-vm/build/jenkins folder by copying the template (jenkins.env.template --> jenkins.env), and adding the details"
  exit 1
fi

# Ensure Mac/Linux compatible properties file
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' 's/ = /=/g' ./jenkins.env
else
  sed -i 's/ = /=/g' ./jenkins.env
fi

# Check the correct number of parameters have been passed
if [[ $# -gt 1 ]]; then
  log_error "You must provide one parameter only\n"
  ${0} -h
  exit 1
fi

# Settings that will be used for provisioning Jenkins, including credentials etc
source ./jenkins.env

# Set shared workspace directory for Vagrant and Terraform jobs
shared_workspace_base_directory_path="$(pwd)/$(basename ${jenkins_shared_workspace})"
git_root_path=$(git rev-parse --show-toplevel)
export shared_workspace_directory_path="${shared_workspace_base_directory_path}/$(basename ${git_root_path})"


# Add OpenSSL binary to PATH if provided in jenkins.env
if [[ -n ${openssl_path} ]]; then
  export PATH=${openssl_path}:${PATH}
  log_info "Using path to OpenSSL provided in jenkins.env --> ${PATH}"
fi

while getopts :hrfi opt; do
  case $opt in
  i)
    override_action="ignore-warnings"
    areYouSureQuestion="Are you sure you want to ignore the warnings and continue anyway?"
    ;;
  r)
    override_action="recreate"
    areYouSureQuestion="Are you sure you want to recreate the secrets file?"
    ;;
  f)
    override_action="fully-recreate"
    areYouSureQuestion="Are you sure you want to recreate the secrets and hash files?"
    ;;
  h)
    echo -e """The $0 script has the following options:
            -i  [i]gnore warnings and start the secret filw generator anyway, knowing that this may cause issues
            -f  [f]ully recreate hash and secrets file
            -h  [h]elp me and show this help text
            -r  [r]ecreate secrets file using existing hash
            """
    exit 0
    ;;
  \?)
    log_error "Invalid option: -$OPTARG. Call \"$0 -h\" to display help text\n${nc}" >&2
    ${0} -h
    exit 1
    ;;
  esac
done

if [[ ${override_action} == "recreate" ]] || [[ ${override_action} == "fully-recreate" ]]; then
  log_info "OK! Proceeding to ${override_action} the secrets file${nc}"
    if [[ -f ./securedCredentials ]]; then
      mv securedCredentials securedCredentials_backup
    fi
    if [[ -f ./credentials_salt ]]; then
      mv credentials_salt credentials_salt_backup
    fi
else
  log_info "You did not pass any option to this script. Exiting."
  -/$0 -h
  exit
fi

# Script is set to start launch environment. Proceeding with checks.
checkVersions "${1}"

if [[ ! -f ./credentials_salt ]]; then
  # Create credentials_salt file
  export credentials_salt=$(openssl rand -base64 12)
  echo ${credentials_salt} >credentials_salt
  log_info "Done. Created credentials_salt file"
fi


if [[ ! -f securedCredentials ]]; then
  # Create encrypted secrets file
  credentialsToStore="git_source_username git_source_password  dockerhub_username dockerhub_password dockerhub_email"
  for credential in ${credentialsToStore}; do
    echo "${credential}:$(echo ${!credential} | openssl enc -aes-256-cbc -pbkdf2 -salt -A -a -pass pass:${credentials_salt})" | tee -a securedCredentials 1>/dev/null
  done
  log_info "Done. Created encrypted secrets file"
fi

