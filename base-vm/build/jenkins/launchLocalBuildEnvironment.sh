#!/bin/bash

# Cleanup for debugging
#ps -ef | grep jenkins.war | grep -v grep | awk {'print $2'} | xargs kill -9 && rm -rf ./jenkins_home

logLevel="info"

# Check if underlying system is Mac or Linux
system=$(uname)

# List all required version prerequisites. These are the versions this script has been tested with.
# In particular Mac OpenSSL will cause issues if not the correct version
vagrantVersionRequired="2.3.4"
virtualboxVersionRequired="7.0.6"
vmwareRequiredVersion="1.17.0"
parallelsVersionRequired="18.2.0"
packerVersionRequired="1.8.6"

# Executable paths if required
if [[ "${system}" == "Darwin" ]]; then
# Mac
  vmWareDiskUtilityPath="/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
  virtualboxCliPath="/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
  vmwareCliPath="/Applications/VMware Fusion.app/Contents/Library/vmrun"
  parallelsCliPath="/Applications/Parallels Desktop.app/Contents/MacOS/prlctl"
  opensslVersionRequired="3.0.5"
elif [[ "${system}" == "Linux" ]]; then
# Linux
  vmWareDiskUtilityPath="/usr/bin/vmware-vdiskmanager"
  virtualboxCliPath="/usr/bin/vboxmanage"
  vmwareCliPath="/usr/bin/vmrun"
  opensslVersionRequired="1.1.1"
else 
  exit 1
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

checkVMWareVersion() {
  checkExecutableExists "${vmWareDiskUtilityPath}" "warn"
  checkExecutableExists "${vmwareCliPath}" "warn"
  checkResponse=$?
  log_debug "checkResponse: ${checkResponse}"
  if [[ "${checkResponse}" -eq 0 ]]; then
    installedVmwareVersion=$("${vmwareCliPath}" | grep version | grep -E -o "([0-9]{1,}\.)+[0-9]{1,}")
    versionCompare "${installedVmwareVersion}" "${vmwareRequiredVersion}" "VMWare"
    ((availableVirtualizationPlatforms++))
  fi
}

checkVirtualBoxVersion() {
  checkExecutableExists "${virtualboxCliPath}" "warn"
  checkResponse=$?
  log_debug "checkResponse: ${checkResponse}"
  if [[ "${checkResponse}" -eq 0 ]]; then
    installedVirtualboxVersion=$(${virtualboxCliPath} --version | grep -E -o "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")
    versionCompare "${installedVirtualboxVersion}" "${virtualboxVersionRequired}" "VirtualBox"
    ((availableVirtualizationPlatforms++))
  fi
}

checkParallelsVersion() {
  checkExecutableExists "${parallelsCliPath}" "warn"
  checkResponse=$?
  if [[ "${checkResponse}" -eq 0 ]]; then
    installedParallelsVersion=$("${parallelsCliPath}" --version | grep -E -o "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")
    versionCompare "${installedParallelsVersion}" "${parallelsVersionRequired}" "Parallels"
    ((availableVirtualizationPlatforms++))
  fi
}

checkVagrantVersion() {
  checkExecutableExists "vagrant" "error"
  checkResponse=$?
  if [[ "${checkResponse}" -eq 0 ]]; then
    installedVagrantVersion=$(vagrant version | grep -E -o "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)" | head -1)
    versionCompare "${installedVagrantVersion}" "${vagrantVersionRequired}" "Vagrant"
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
  availableVirtualizationPlatforms=0

  log_info "Launching version checks..."
  checkVMWareVersion
  log_debug "checkErrors 1: ${checkErrors}"
  checkVirtualBoxVersion
  if [[ "${system}" == "Darwin" ]]; then
    checkParallelsVersion
  fi
  log_debug "checkErrors 2: ${checkErrors}"
  checkVagrantVersion
  log_debug "checkErrors 3: ${checkErrors}"
  checkOpenSSLVersion
  log_debug "checkErrors 4: ${checkErrors}"
  log_debug "Errors: ${checkErrors}"
  log_debug "Warnings: ${checkWarnings}"
  log_debug "Available Virtualization Platforms: ${availableVirtualizationPlatforms}"
  if [[ "${availableVirtualizationPlatforms}" -eq 0 ]]; then
    log_error "There are no virtualization platforms installed. Please install either VMWare Desktop/Fusion, VirtualBox or Parallels (Mac only), and try again"
  fi

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
    message=${1}
    colour=${2:-nc}
    if [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "${!colour}[DEBUG] ${message}${nc}"
    fi
}

log_error() {
    message=${1}
    colour=${2:-red}
    if [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "${!colour}[ERROR] ${message}${nc}"
    fi
}

log_info() {
    message=${1}
    colour=${2:-nc}
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "${!colour}[INFO] ${message}${nc}"
    fi
}

log_trace() {
    message=${1}
    colour=${2:-nc}
    if [[ "${logLevel}" == "trace" ]]; then
        >&2 echo -e "${!colour}[TRACE] ${message}${nc}"
    fi
}

log_warn() {
    message=${1}
    colour=${2:-orange}
    if [[ "${logLevel}" == "info" ]] || [[ "${logLevel}" == "error" ]] || [[ "${logLevel}" == "warn" ]] || [[ "${logLevel}" == "debug" ]]; then
        >&2 echo -e "${!colour}[WARN] ${message}${nc}"
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

while getopts :dhrsfui opt; do
  case $opt in
  i)
    override_action="ignore-warnings"
    areYouSureQuestion="Are you sure you want to ignore the warnings and continue anyway?"
    ;;
  r)
    override_action="recreate"
    areYouSureQuestion="Are you sure you want to recreate the jobs in the jenkins environment?"
    ;;
  d)
    override_action="destroy"
    areYouSureQuestion="Are you sure you want to destroy and rebuild the jenkins environment, losing all history?"
    ;;
  f)
    override_action="fully-destroy"
    areYouSureQuestion="Are you sure you want to fully destroy and rebuild the jenkins environment, losing all history, virtual-machines and built images?"
    ;;
  u)
    override_action="uninstall"
    areYouSureQuestion="Are you sure you want to uninstall the jenkins environment?"
    ;;
  s)
    override_action="stop"
    areYouSureQuestion="Are you sure you want to stop the jenkins environment?"
    ;;
  h)
    echo -e """The $0 script has the following options:
            -i  [i]gnore warnings and start the launcher anyway, knowing that this may cause issues
            -d  [d]estroy and rebuild Jenkins environment. All history is also deleted
            -f  [f]ully destroy and rebuild, including ALL built images and ALL KX.AS.CODE virtual machines!
            -h  [h]elp me and show this help text
            -r  [r]ecreate Jenkins jobs with updated parameters. Will keep history
            -s  [s]top the Jenkins build environment
            -u  [u]ninstall and give me back my disk space\n
            """
    exit 0
    ;;
  \?)
    log_error "Invalid option: -$OPTARG. Call \"$0 -h\" to display help text\n" >&2
    ${0} -h
    exit 1
    ;;
  esac
done

# Stop Jenkins if so desired
if [[ ${override_action} == "stop" ]]; then
  log_warn "This will not stop the KX.AS.CODE VMs. You need to use the jenkins run job to \"halt\" the environment"
  log_info "Stopping the KX.AS.CODE Jenkins environment..."
  log_info "Stopping the Jenkins process..."
  screen -wipe -q >/dev/null
  ps -ef | grep jenkins.war | grep -v grep | awk {'print $2'} | xargs kill -9
  log_info "Stopped the Jenkins process"
  exit 0
fi

if [[ ${override_action} == "recreate" ]] || [[ ${override_action} == "destroy" ]] || [[ ${override_action} == "fully-destroy" ]] || [[ ${override_action} == "uninstall" ]]; then
  echo -e "${red}${areYouSureQuestion} [Y/N]${nc} "
  read -r REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "OK! Proceeding to ${override_action} the KX.AS.CODE Jenkins environment"
    screen -wipe -q >/dev/null
    ps -ef | grep jenkins.war | grep -v grep | awk {'print $2'} | xargs kill -9
    log_info "Deleting Jenkins jobs..."
    find ./jenkins_home/jobs -type f -name "config.xml" -exec rm -f {} \; 2>/dev/null || true
    if [[ ${override_action} == "destroy" ]] || [[ ${override_action} == "fully-destroy" ]] || [[ ${override_action} == "uninstall" ]]; then
      log_info "Deleting Jenkins war file..."
      rm -f ./jenkins.war
      log_info "Deleting jenkins_home directory..."
      rm -rf ./jenkins_home ./.hash ./.vmCredentialsFile ./jenkinsLog*.txt || true
      if [[ ${override_action} == "fully-destroy" ]]; then
        log_info "Deleting jenkins workspace..."
        rm -rf ${shared_workspace_base_directory_path} || true
      fi
      log_info "Deleting downloaded tools..."
      rm -rf ./jq ./java ./amazon-corretto*.tar.gz ./jenkins-cli.jar ./mo ./jenkins-plugin-manager.jar || true
    fi
    if [[ ${override_action} == "uninstall" ]] ||  [[ ${override_action} == "destroy" ]] || [[ ${override_action} == "fully-destroy" ]]; then
      log_info "Uninstall complete"
      exit 0
    fi
  fi
fi

# Script is set to start launch environment. Proceeding with checks.
checkVersions "${1}"

# Versions that will be downloaded if already installed binaries not found
javaDownloadVersion=11.0.3.7.1
jqDownloadVersion=1.6

# Determine OS this script is running on and set appropriate download links and commands
case $(uname -s) in

Linux)
  log_info "Script running on Linux. Setting appropriate download links"
  javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-linux-x64.tar.gz"
  jqInstallerUrl="https://github.com/stedolan/jq/releases/download/jq-${jqDownloadVersion}/jq-linux64"
  os=linux
  ;;
Darwin)
  log_info "Script running on Darwin. Setting appropriate download links"
  javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-macosx-x64.tar.gz"
  jqInstallerUrl="https://github.com/stedolan/jq/releases/download/jq-${jqDownloadVersion}/jq-osx-amd64"
  os=darwin
  ;;
*)
  log_info "Script running on Windows. Setting appropriate download links"
  javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-windows-x64.zip"
  jqInstallerUrl="https://github.com/stedolan/jq/releases/download/jq-${jqDownloadVersion}/jq-win64.exe"
  os=windows
  ;;
esac

log_debug "Set java download link to: ${javaInstallerUrl}"
log_debug "Set jq download link to: ${jqInstallerUrl}"

# Check if jq is installed
jqBinaryWhich=$(which jq | sed 's;jq not found;;g')
jqBinaryLocal=$(find ./ -type f \( -name "jq" -or -name "jq.exe" \))
jqBinary=${jqBinaryWhich:-${jqBinaryLocal}}

if [[ -z ${jqBinary} ]]; then
  log_info "jq is not installed or not reachable. Downloading from https://github.com/stedolan/jq/releases/download/"
  curl -# -L -s -o ./jq ${jqInstallerUrl}
  chmod 755 ./jq
  if [[ $os == "windows" ]]; then
    mv ./jq ./jq.exe
    jqBinary="./jq.exe"
  else
    jqBinary="./jq"
  fi
  if [[ -f ./jq ]]; then
    jqBinary=./jq
  elif [[ -f ./jq.exe ]]; then
    jqBinary=./jq.exe
  else
    jqBinary=$(which jq)
    if [[ $? -ne 0 ]]; then
      log_error "jq not found and could not be downloaded/installed. Exiting"
      exit 1
    fi
  fi
fi

# Download and install Java
log_info "Downloading Java from https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html"
mkdir -p java
base=${javaInstallerUrl%.*}
ext=${javaInstallerUrl#$base.}
if [[ ${ext} == "gz" ]]; then
  curl -# -o amazon-corretto-11-x64-linux-jdk.tar.gz -L ${javaInstallerUrl}
  tar tzf amazon-corretto-11-x64-linux-jdk.tar.gz >/dev/null
  if [[ $? -ne 0 ]]; then
    log_error "The downloaded Java compressed tar.gz file does not seem to be valid. Please check your internet connection and try again"
    exit 1
  fi
  log_info "The downloaded Java compressed tar.gz file seems to be complete. Extracting files and continuing"
  tar xzf amazon-corretto-11-x64-linux-jdk.tar.gz -C ./java --strip-components=1 >/dev/null
fi
javaBinary=$(find ./java -type f -name "java")
if [[ -z ${javaBinary} ]]; then
  log_error "Java not found and could not be downloaded/installed. Exiting"
  exit 1
fi
error="false"

if [ -d ${jenkins_home} ] && [[ ${override_action} != "recreate" ]] && [[ ${override_action} != "destroy" ]] && [[ ${override_action} != "fully-destroy" ]]; then
  log_info "${jenkins_home} already exists. Will skip Jenkins setup. Delete or rename ${jenkins_home} if you want to re-install Jenkins"
fi

firstTwoChars=$(echo "${jenkins_home}" | head -c2)
firstChar=$(echo "${jenkins_home}" | head -c1)
if [[ ${firstTwoChars} == "./" ]]; then
  # if workspace directory starts with ./, convert relative directory to absolute
  jenkins_home_absolute_path=$(pwd)/$(echo ${jenkins_home} | sed 's;\./;;g')
elif [[ ${firstChar} == "/" ]]; then
  # If / at start, assume provided directory is already absolute and use it
  jenkins_home_absolute_path=${jenkins_home}
elif [[ ${firstTwoChars} == ".\\" ]]; then
  # if workspace directory starts with .\, convert relative directory to absolute
  jenkins_home_absolute_path=$(pwd)/$(echo ${jenkins_home} | sed 's/\.//g')
else
  # If no ./ or / at beginning, assume relative working directory and convert to absolute
  jenkins_home_absolute_path="$(pwd)/${jenkins_home}"
fi
jenkins_home=${jenkins_home_absolute_path}
log_info "Setting jenkins_home to ${jenkins_home_absolute_path}"

# Copy Initial Setup files to Jenkins Home
cp -rf ./initial-setup/. jenkins_home/

# Update Jenkins userContent file
mkdir -p jenkins_home/userContent/
cp -rf ./initial-setup/userContent/. jenkins_home/userContent/

# Download and update Jenkins WAR file with needed plugins
jenkinsDownloadVersion="2.332.2"
jenkinsWarFileUrl="https://get.jenkins.io/war-stable/${jenkinsDownloadVersion}/jenkins.war"
if [ ! -f ./jenkins.war ]; then
  # Download Jenkins WAR file
  log_info "Downloading Jenkins WAR file..."
  curl -# -L -o jenkins.war ${jenkinsWarFileUrl}
fi

# Check if plugin manager already downloaded or not
if [ ! -f ./jenkins-plugin-manager.jar ]; then
  # Install Jenkins Plugins
  jenkinsPluginManagerVersion="2.12.8"
  log_info "Downloading Jenkins Plugin Manager..."
  log_debug "curl -s -L -o ./jenkins-plugin-manager.jar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${jenkinsPluginManagerVersion}/jenkins-plugin-manager-${jenkinsPluginManagerVersion}.jar"
  curl -# -L -o ./jenkins-plugin-manager.jar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${jenkinsPluginManagerVersion}/jenkins-plugin-manager-${jenkinsPluginManagerVersion}.jar
fi

# Download plugins if not yet installed
mkdir -p ${jenkins_home}/plugins
availablePlugins=$(ls ${jenkins_home}/plugins)
if [ -z "${availablePlugins}" ]; then
  #jenkinsDeliveryPipelinePluginVersion="1.4.2"
  #echo "${javaBinary} -jar ./jenkins-plugin-manager.jar --war ./jenkins.war --plugin-download-directory ${jenkins_home}/plugins --plugin-file ./initial-setup/plugins.txt --plugins delivery-pipeline-plugin:${jenkinsDeliveryPipelinePluginVersion} deployit-plugin"
  log_debug "${javaBinary} -jar ./jenkins-plugin-manager.jar --war ./jenkins.war --plugin-download-directory ${jenkins_home}/plugins --plugin-file ./initial-setup/plugins.txt"
  for i in {1..5}
  do
    ${javaBinary} -jar ./jenkins-plugin-manager.jar --war ./jenkins.war --plugin-download-directory ${jenkins_home}/plugins --plugin-file ./initial-setup/plugins.txt
    if [[ -f ${jenkins_home}/plugins/build-monitor-plugin.jpi ]]; then
      log_info "Seems plugins downloaded OK. Continuing."
      break
    else
      log_warn "Seems not all plugins downloaded OK. Will try again"
    fi
  done
  # Final check - exit with non-zero error code if still not all plugins available
  if [[ ! -f ${jenkins_home}/plugins/build-monitor-plugin.jpi ]]; then
      log_error "${jenkins_home}/plugins/build-monitor-plugin plugin still missing. Exiting with non-zero return code."
      exit 1
  fi
fi


# Bypass Jenkins setup wizard
if [ ! -f ${jenkins_home}/jenkins.install.UpgradeWizard.state ]; then
  echo "${jenkinsDownloadVersion}" >${jenkins_home}/jenkins.install.UpgradeWizard.state
fi

# Bypass Jenkins setup wizard
if [ ! -f ${jenkins_home}/jenkins.install.InstallUtil.lastExecVersion ]; then
  echo "${jenkinsDownloadVersion}" >${jenkins_home}/jenkins.install.InstallUtil.lastExecVersion
fi

# Create shared workspace directory for Vagrant and Terraform jobs
if [[ ! -L ${shared_workspace_directory_path} ]] && [[ ! -e ${shared_workspace_directory_path} ]]; then
  mkdir -p ${shared_workspace_base_directory_path}
  ln -s ${git_root_path} ${shared_workspace_base_directory_path}
fi

# Replace variable placeholders in Jenkins jobs
OLD_IFS=${IFS}
IFS=$'\n'
# Download tool for replacing mustache variables
if [[ ! -f ./mo ]]; then
  curl -# -SL https://git.io/get-mo -o mo
  chmod +x ./mo
fi

# Setting default values. Created for Windows ps1 script, but still needs to be populated here.
export path_to_git_executable="git"
export path_to_sh_executable="sh"

initialSetupJobConfgXmlFiles=$(find jenkins_home -not \( -path jenkins_home/plugins -prune \) -not \( -path jenkins_home/war -prune \) -not \( -path jenkins_home/fingerprints -prune \) -name "*.xml" -maxdepth 5 | grep -v "credential_")
for initialSetupJobConfgXmlFile in ${initialSetupJobConfgXmlFiles}; do
  log_info "Replacing placeholders with values in ${initialSetupJobConfgXmlFile}"
  for i in {1..5}; do
    # Get list of variables to replace
    placeholdersToReplace=$(sed -n 's/.*{{\(.*[a-z_]\)}}.*/\1/p' ${initialSetupJobConfgXmlFile})
    log_debug ${placeholdersToReplace}
    cp -f ${initialSetupJobConfgXmlFile} ${initialSetupJobConfgXmlFile}_tmp
    for placeholder in ${placeholdersToReplace}; do
      log_debug ${placeholder}
      log_debug ${!placeholder}
      log_debug ${initialSetupJobConfgXmlFile}_tmp
      if [[ "$(uname)" == "Darwin" ]]; then
        sed -E -i '' "s|\{\{${placeholder}\}\}|${!placeholder}|g" ${initialSetupJobConfgXmlFile}_tmp
      else
        sed -E -i "s|\{\{${placeholder}\}\}|${!placeholder}|g" ${initialSetupJobConfgXmlFile}_tmp
      fi
    done
    if [ -s "${initialSetupJobConfgXmlFile}_tmp" ]; then
      cp -f "${initialSetupJobConfgXmlFile}_tmp" "${initialSetupJobConfgXmlFile}"
      rm -f "${initialSetupJobConfgXmlFile}_tmp"
      break
    else
      log_error "Target ${initialSetupJobConfgXmlFile} file was empty after mustach replacement. Trying again"
    fi
  done
done
IFS=${OLD_IFS}

# Set jenkins_home and start Jenkins
# Start manually for debugging with Start-Process -FilePath .\java\jdk11.0.3_7\bin\java.exe -ArgumentList "-jar", ".\jenkins.war", "--httpListenAddress=127.0.0.1", "--httpPort=8081"
export JENKINS_HOME="$(pwd)/jenkins_home"
# TODO - Test Git paths on line below. Currently hardcoded for debugging
screen -wipe -q >/dev/null
screen -L -Logfile ./jenkinsLog_$(date '+%Y%m%d_%H%M%S').txt -S jenkins -d -m ${javaBinary} -jar ./jenkins.war --httpListenAddress=${jenkins_listen_address} --httpPort=${jenkins_server_port} -q >/dev/null

jenkins_url="http://${jenkins_listen_address}:${jenkins_server_port}"

# Downloading Jenkins CLI used for creating Jenkins credentials
log_warn "The next steps - downloading Jar files from Jenkins - might take a few minutes, as Jenkins needs to finish coming up before it will work"
log_info "Waiting for jenkins-cli.jar to become available..."
while [[ ! -f ./jenkins-cli.jar ]]; do
  for i in {1..60}; do
    http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${jenkins_url}/jnlpJars/jenkins-cli.jar || true)
    if [[ ${http_code} == "200" ]]; then
      curl -# ${jenkins_url}/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
      break 2
    fi
    log_info "Waiting for ${jenkins_url}/jnlpJars/jenkins-cli.jar [RC=${http_code}]"
    sleep 30
  done
done

# Check if Jenkins CLI is now available, if not exit script with error
if [[ ! -f ./jenkins-cli.jar ]]; then
  log_error "Jenkins jenkins-cli.jar is still not available even after 30 minutes. It should not take this long for Jenkins to start..."
  exit 1
fi

# In case jars already existed, add an additional check to wait for RC200
log_info "Waiting for Jenkins to be fully up before continuing..."
for i in {1..60}; do
  http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${jenkins_url}/view/Status/ || true)
  if [[ ${http_code} == "200" ]]; then
    log_info "Jenkins is up, continuing with setting up the build & deploy environment"
    break
  fi
  log_info "Waiting for ${jenkins_url}/view/Status/ [RC=${http_code}]"
  sleep 30
done

# Get Jenkins Crumb
export jenkinsCrumb=$(curl -s --cookie-jar /tmp/cookies -u admin:admin ${jenkins_url}/crumbIssuer/api/json | ${jqBinary} -r '.crumb')

# Generated encrypted secret file to upload to Jenkins
$(pwd)/generateSecretsFile.sh -r

# Read hash created by above script
export hash=$(cat ./.hash | head -1)
log_debug "Extracted hash from previous script call: *${hash}*" "orange"

# Creating credentials in Jenkins
credentialXmlFiles=$(find ./jenkins_home -name "credential_*.xml")
for credentialXmlFile in ${credentialXmlFiles}; do
  log_info "Replacing placeholders with values in ${credentialXmlFile}"
  for i in {1..5}; do
    cat "${credentialXmlFile}" | ./mo >"${credentialXmlFile}_mo"
    if [[ "${system}" == "Linux" ]]; then
      export credentialId=$(cat "${credentialXmlFile}" | grep -oPm1 "(?<=<id>)[^<]+")
    elif [[ "${system}" == "Darwin" ]]; then
      export credentialId=$(cat "${credentialXmlFile}" | grep '<id>' "${credentialXmlFile}" | sed 's@.*<id>\(.*\)</id>.*@\1@')
    fi
    if [ -s "${credentialXmlFile}_mo" ]; then
      # Remove credential before creating/recreating it
      log_debug "curl -X GET --cookie /tmp/cookies -H \"Jenkins-Crumb: ${jenkinsCrumb}\" -u admin:admin ${jenkins_url}/credentials/store/system/domain/_/credential/${credentialId} -L -s -o /dev/null -w \"%{http_code}\""
      httpResponseCode=$(curl -X GET --cookie /tmp/cookies -H "Jenkins-Crumb: ${jenkinsCrumb}" -u admin:admin ${jenkins_url}/credentials/store/system/domain/_/credential/${credentialId} -L -s -o /dev/null -w "%{http_code}")
      if [[ "${httpResponseCode}" == "200" ]]; then
        log_debug "curl -X POST --cookie /tmp/cookies -H \"Jenkins-Crumb: ${jenkinsCrumb}\" -u admin:admin ${jenkins_url}/credentials/store/system/domain/_/credential/${credentialId}/doDelete"
        log_info "Deleting credential with id ${credentialId} so it can be recreated"
        curl -X POST --cookie /tmp/cookies -H "Jenkins-Crumb: ${jenkinsCrumb}" \
          -u admin:admin \
          ${jenkins_url}/credentials/store/system/domain/_/credential/${credentialId}/doDelete
      else
        log_debug "Nothing to delete, as credential ${credentialId} did not exit yet" "orange"
      fi
      cat "${credentialXmlFile}_mo" | "${javaBinary}" -jar jenkins-cli.jar -s ${jenkins_url} create-credentials-by-xml system::system::jenkins _ || true
      rm -f "${credentialXmlFile}_mo"
      rm -f "${credentialXmlFile}"
      break
    else
      log_error "Target config.xml file was empty after mustach replacement. Trying again"
    fi
  done
done

# Delete credential in order to update/recreate it in next step
httpResponseCode=$(curl -X GET --cookie /tmp/cookies -H "Jenkins-Crumb: ${jenkinsCrumb}" -u admin:admin ${jenkins_url}/credentials/store/system/domain/_/credential/VM_CREDENTIALS_FILE -L -s -o /dev/null -w "%{http_code}")
if [[ "${httpResponseCode}" == "200" ]]; then
 log_debug "curl -X POST --cookie /tmp/cookies -H \"Jenkins-Crumb: ${jenkinsCrumb}\" -u admin:admin ${jenkins_url}/credentials/store/system/domain/_/credential/VM_CREDENTIALS_FILE/doDelete"
 curl -X POST --cookie /tmp/cookies -H "Jenkins-Crumb: ${jenkinsCrumb}" \
     -u admin:admin \
      ${jenkins_url}/credentials/store/system/domain/_/credential/VM_CREDENTIALS_FILE/doDelete
else
  log_debug "Nothing to delete, as credential VM_CREDENTIALS_FILE did not exit yet" "orange"
fi

# Post encrypted file to Jenkins as a credential
curl -s -X POST --cookie /tmp/cookies -H "Jenkins-Crumb: ${jenkinsCrumb}" -u admin:admin \
  ${jenkins_url}/credentials/store/system/domain/_/createCredentials \
  -F securedCredentials=@$(pwd)/.vmCredentialsFile \
  -F 'json={"": "4", "credentials": {"file": "securedCredentials", "id": "VM_CREDENTIALS_FILE", "description": "KX.AS.CODE credentials", "stapler-class": "org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl", "$class": "org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl"}}'

#TODO Move this check to be with other checks at the beginning of the script
# Optional tool only needed for Vagrant VMWare profiles
ovftoolInstalled=$(ovftool --version 2>/dev/null | grep -E "VMware ovftool ([0-9]+)\.([0-9]+)\.([0-9]+)" || true)
if [[ -z ${ovftoolInstalled} ]]; then
  log_warn "Optional VMWare OVFTool not installed or not reachable. Download OVTOool from https://code.vmware.com/web/tool/4.4.0/ovf and ensure it is reachable on your PATH"
  warning="true"
fi

if [[ ${warning} == "true" ]]; then
  log_warn "One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images"
  log_warn "Do you wish to continue anyway?"
  select yn in "Yes" "No"; do
    case $yn in
    Yes)
      log_info "[Yes], Continuing..."
      break
      ;;
    No)
      log_info "[No], Exiting script..."
      exit 1
      ;;
    esac
  done
fi

if [[ ${error} == "true" ]]; then
  log_error "One or more components required to successfully build packer images for KX.AS.CODE were missing. Please resolve errors and try again"
  exit 1
fi

log_info "Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL:" "green"
log_info "${jenkins_url}/job/KX.AS.CODE_Launcher/build?delay=0sec" "blue"
