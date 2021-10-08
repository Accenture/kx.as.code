#!/bin/bash

# Define ansi colours
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[36m"
nc="\033[0m" # No Color

override_action=""
error=""

# Source the user configured env file before creating the KX.AS.CODE Jenkins environment
if [ ! -f ./jenkins.env ]; then
    echo -e "${red}- [ERROR] Please create the jenkins.env file in the base-vm/build/jenkins folder by copying the template (jenkins.env.template --> jenkins.env), and adding the details"
    exit 1
fi

# Ensure Mac/Linux compatible properties file
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' 's/ = /=/g' ./jenkins.env
else
    sed -i 's/ = /=/g' ./jenkins.env
fi

# Source variables in jenkins.env file
set -a
. ./jenkins.env
set +a

# Check the correct number of parameters have been passed
if [[ $# -gt 1 ]]; then
    echo -e "${red}- [ERROR] You must provide one parameter only\n${nc}"
    ${0} -h
    exit 1
fi

# Settings that will be used for provisioning Jenkins, including credentials etc
source ./jenkins.env

while getopts :dhrsfu opt; do
    case $opt in
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
            -d  [d]estroy and rebuild Jenkins environment. All history is also deleted
            -f  [f]ully destroy and rebuild, including ALL built images and ALL KX.AS.CODE virtual machines!
            -h  [h]elp me and show this help text
            -r  [r]ecreate Jenkins jobs with updated parameters. Will keep history
            -s  [s]op the Jenkins build environment
            -u  [u]ninstall and give me back my disk space\n
            """
            exit 0
            ;;
        \?)
            echo -e "${red}[ERROR] Invalid option: -$OPTARG. Call \"$0 -h\" to display help text\n${nc}" >&2
            ${0} -h
            exit 1
            ;;
    esac
done

# Stop Jenkins if so desired
if [[ ${override_action} == "stop"   ]]; then
    echo -e "${orange}- [WARN] This will not stop the KX.AS.CODE VMs. You need to use the jenkins run job to \"halt\" the environment"
    echo -e "- [INFO] Stopping the KX.AS.CODE Jenkins environment..."
    echo -e "- [INFO] Killing the agent..."
    killall agent.jar || true
    echo -e "- [INFO] Jenkins Agent killed"
    echo -e "- [INFO] Stopping the Docker container..."
    docker stop jenkins || true
    echo -e "- [INFO] Stopped the Jenkins container"
    exit 0
fi

if [[ ${override_action} == "recreate"   ]] || [[ ${override_action} == "destroy"   ]] || [[ ${override_action} == "fully-destroy"   ]] || [[ ${override_action} == "uninstall"   ]]; then
    echo -e "${red}${areYouSureQuestion} [Y/N]${nc} "
    read -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${red}- [INFO] OK! Proceeding to ${override_action} the KX.AS.CODE Jenkins environment${nc}"
        echo -e "${red}- [INFO] Deleting Jenkins jobs...${nc}"
        find ./jenkins_home/jobs -type f -name "config.xml" -exec rm -f {} \; || true
        echo -e "${red}- [INFO] Deleting Docker container...${nc}"
        docker rm -f jenkins || true
        echo -e "${red}- [INFO] Docker container deleted${nc}"
        echo -e "${red}- [INFO] Jenkins jobs deleted${nc}"
        if [[ ${override_action} == "destroy" ]] || [[ ${override_action} == "fully-destroy"   ]] || [[ ${override_action} == "uninstall"   ]]; then
            echo -e "${red}- [INFO] Deleting Jenkins image...${nc}"
            docker rmi "$(docker images "${kx_jenkins_image}" -q)" || true
            echo -e "${red}- [INFO] Docker image deleted${nc}"
            echo -e "${red}- [INFO] Deleting jenkins_home directory...${nc}"
            rm -rf ./jenkins_home || true
            echo -e "${red}- [INFO] jenkins_home deleted${nc}"
            if [[ ${override_action} == "fully-destroy" ]]; then
                echo -e "${red}- [INFO] Deleting jenkins_remote directory...${nc}"
                rm -rf ./jenkins_remote || true
                echo -e "${red}- [INFO] jenkins_remote deleted${nc}"
            fi
            echo -e "${red}- [INFO] Deleting downloaded tools...${nc}"
            rm -rf ./jq ./java ./agent.jar ./jenkins-cli.jar ./mo ./docker-compose || true
            echo -e "${red}- [INFO] Downloaded tools deleted${nc}"
        fi
        if [[ ${override_action} == "uninstall" ]]; then
            echo -e "Uninstall complete"
            exit 0
        fi
    fi
fi

# Versions that will be downloaded if already installed binaries not found
composeDownloadVersion=1.29.2
javaDownloadVersion=11.0.3.7.1
jqDownloadVersion=1.6

# Determine OS this script is running on and set appropriate download links and commands
case $(uname -s) in

    Linux)
        echo -e "${blue}- [INFO] Script running on Linux. Setting appropriate download links${nc}"
        dockerComposeInstallerUrl="https://github.com/docker/compose/releases/download/${composeDownloadVersion}/docker-compose-Linux-x86_64"
        javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-linux-x64.tar.gz"
        jqInstallerUrl="https://github.com/stedolan/jq/releases/download/jq-${jqDownloadVersion}/jq-linux64"
        os=linux
        ;;
    Darwin)
        echo -e "${blue}- [INFO] Script running on Darwin. Setting appropriate download links${nc}"
        dockerComposeInstallerUrl="https://github.com/docker/compose/releases/download/${composeDownloadVersion}/docker-compose-Darwin-x86_64"
        javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-macosx-x64.tar.gz"
        jqInstallerUrl="https://github.com/stedolan/jq/releases/download/jq-${jqDownloadVersion}/jq-osx-amd64"
        os=darwin
        ;;
    *)
        echo -e "${blue}- [INFO] Script running on Windows. Setting appropriate download links${nc}"
        dockerComposeInstallerUrl="https://github.com/docker/compose/releases/download/${composeDownloadVersion}/docker-compose-Windows-x86_64.exe"
        javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-windows-x64.zip"
        jqInstallerUrl="https://github.com/stedolan/jq/releases/download/jq-${jqDownloadVersion}/jq-win64.exe"
        os=windows
        ;;
esac

echo "- [INFO] Set docker-compose download link to: ${dockerComposeInstallerUrl}"
echo "- [INFO] Set java download link to: ${javaInstallerUrl}"
echo "- [INFO] Set jq download link to: ${jqInstallerUrl}"

# Check if Docker-Compose is installed
dockerComposeBinaryWhich=$(which docker-compose | sed 's;docker-compose not found;;g')
dockerComposeBinaryLocal=$(find ./ -type f \( -name "docker-compose" -or -name "docker-compose.exe" \))
dockerComposeBinary=${dockerComposeBinaryWhich:-${dockerComposeBinaryLocal}}
if [[ -z ${dockerComposeBinary}   ]]; then
    echo -e "${blue}- [INFO] Docker-compose is not installed or not reachable. Downloading from https://docs.docker.com/compose/install/${nc}"
    curl -L -s -o ./docker-compose ${dockerComposeInstallerUrl}
    chmod 755 ./docker-compose
    if [[ $os == "windows" ]]; then
        mv ./docker-compose ./docker-compose.exe
        dockerComposeBinary="./docker-compose.exe"
    else
        dockerComposeBinary="./docker-compose"
    fi
    if [[ -f ./docker-compose ]]; then
        dockerComposeBinary=./docker-compose
    elif [[ -f ./docker-compose.exe ]]; then
        dockerComposeBinary=./docker-compose.exe
    else
        dockerComposeBinary=$(which docker-compose)
        if [[ $? -ne 0 ]]; then
            echo -e "${red}[ERROR] docker-compose not found and could not be downloaded/installed. Exiting${nc}"
            exit 1
        fi
    fi
fi

# Check if jq is installed
jqBinaryWhich=$(which jq | sed 's;jq not found;;g')
jqBinaryLocal=$(find ./ -type f \( -name "jq" -or -name "jq.exe" \))
jqBinary=${jqBinaryWhich:-${jqBinaryLocal}}
if [[ -z ${jqBinary}   ]]; then
    echo -e "${blue}- [INFO] jq is not installed or not reachable. Downloading from https://github.com/stedolan/jq/releases/download/${nc}"
    curl -L -s -o ./jq ${jqInstallerUrl}
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
            echo -e "${red}[ERROR] jq not found and could not be downloaded/installed. Exiting${nc}"
            exit 1
        fi
    fi
fi

# Check if correct version
dockerComposeVersion=$("${dockerComposeBinary}" -v 2> /dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
minimalComposeVersion=1.25.0
if [[ "$(printf '%s\n' "${minimalComposeVersion}" "${dockerComposeVersion}" | sort -V | head -n1)" == "${dockerComposeVersion}" ]]; then
    echo -e "${blue}- [INFO] You are using an outdated docker-compose executable, which means --env-file option will not be present. Downloading updated version from https://docs.docker.com/compose/install/${nc}"
    curl -L -s -o ./docker-compose ${dockerComposeInstallerUrl}
    chmod 755 ./docker-compose
    dockerComposeBinary="./docker-compose"
else
    echo -e "${green}- [INFO] All good with docker-compose. Proceeding...${nc}"
fi

# Check if Docker is installed
dockerInstalled=$(docker -v 2> /dev/null | grep -E "Docker version ([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${dockerInstalled} ]]; then
    echo -e "${red}- [ERROR] Docker not installed or not reachable. Read the guide for you distribution for how to install docker. Also, check your user has permissions to access Docker and that is is reachable on the PATH${nc}"
    error="true"
fi

# Check if Java is installed
if [[ ${forceJavaInstall} == "true"   ]]; then
    echo -e "${red}- [INFO] Java forced install flag set. Ignoring any locally installed Java and proceeding to download Java for this Jenkins environment${nc}"
    javaBinaryWhich=""
else
    javaBinaryWhich=$(which java | sed 's;java not found;;g')
fi
javaBinaryLocal=$(find ./java -type f -name "java" 2> /dev/null || true)
javaBinary=${javaBinaryWhich:-${javaBinaryLocal}}
if [[ -z ${javaBinary}   ]]; then
    javaInstalled=$(${javaBinary} --version 2> /dev/null | head -1 | grep -E ".*([0-9]+)\.([0-9]+)\.([0-9]+).*")
    if [[ -z ${javaInstalled} ]]; then
        echo -e "${blue}- [INFO] Java not installed or not reachable. Will download Java from https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html${nc}"
        mkdir -p java
        base=${javaInstallerUrl%.*}
        ext=${javaInstallerUrl#$base.}
        if [[ ${ext} == "gz" ]]; then
            curl -s -o amazon-corretto-11-x64-linux-jdk.tar.gz -L ${javaInstallerUrl}
            tar tzf amazon-corretto-11-x64-linux-jdk.tar.gz 1> /dev/null 2> /dev/null
            if [[ $? -ne 0 ]]; then
                echo -e "${red}- [ERROR] The downloaded Java compressed tar.gz file does not seem to be valid. Please check your internet connection and try again${nc}"
                exit 1
            fi
            echo -e "${blue}- [INFO] The downloaded Java compressed tar.gz file seems to be complete. Extracting files and continuing${nc}"
            tar xvzf amazon-corretto-11-x64-linux-jdk.tar.gz -C ./java --strip-components=1
        fi
        javaBinary=$(find ./java -type f -name "java")
        if [[ -z ${javaBinary} ]]; then
            echo -e "${red}[ERROR] Java not found and could not be downloaded/installed. Exiting${nc}"
            exit 1
        fi
        error="false"
    fi
fi

if [ -d ${jenkins_home} ] && [[ ${override_action} != "recreate"   ]] && [[ ${override_action} != "destroy"   ]] && [[ ${override_action} != "fully-destroy"   ]]; then
    echo -e "${blue}- [INFO] ${jenkins_home} already exists. Will skip Jenkins setup. Delete or rename ${jenkins_home} if you want to re-install Jenkins${nc}"
fi

# Checking if running on docker-machine to set correct Jenkins URL
if [[ $(docker -D info --format '{{json .}}' | ${jqBinary} -r '.KernelVersion') =~ boot2docker ]]; then

    echo -e "${blue}- [INFO] Jenkins is running on docker-machine, setting docker host to 192.168.99.100${nc}"
    jenkins_host=192.168.99.100
    jenkins_url=http://${jenkins_host}:${jenkins_server_port}
else
    echo -e "${blue}- [INFO] Not a docker-machine environment, setting docker host to localhost${nc}"
    jenkins_host=localhost
    jenkins_url=http://${jenkins_host}:${jenkins_server_port}
fi

# Building Docker Image if it does not exist
if [[ -z $(docker images ${kx_jenkins_image} -q) ]]; then
    echo -e "${blue}- [INFO] Image ${kx_jenkins_image} not present on this machine. Building...${nc}"
    docker build -t ${kx_jenkins_image} ./initial-setup
    if [[ $? -ne 0 ]]; then
        echo -e "${red}- [INFO] Build of image ${kx_jenkins_image} failed${nc}"
    else
        echo -e "${green}- [INFO] Build of image ${kx_jenkins_image} completed successfully${nc}"
    fi
fi

firstTwoChars=$(echo "${working_directory}" | head -c2)
firstChar=$(echo "${working_directory}" | head -c1)
if [[ ${firstTwoChars} == "./" ]]; then
    # if workspace directory starts with ./, convert relative directory to absolute
    workdir_absolute_path=$(pwd)/$(echo ${working_directory} | sed 's;\./;;g')
elif [[ ${firstChar} == "/" ]]; then
    # If / at start, assume provided directory is already absolute and use it
    workdir_absolute_path=${working_directory}
else
    # If no ./ or / at beginning, assume relative working directory and convert to absolute
    workdir_absolute_path="$(pwd)/${working_directory}"
fi
working_directory=${workdir_absolute_path}

firstTwoChars=$(echo "${jenkins_home}" | head -c2)
firstChar=$(echo "${jenkins_home}" | head -c1)
if [[ ${firstTwoChars} == "./" ]]; then
    # if workspace directory starts with ./, convert relative directory to absolute
    jenkins_home_absolute_path=$(pwd)/$(echo ${jenkins_home} | sed 's;\./;;g')
elif [[ ${firstChar} == "/" ]]; then
    # If / at start, assume provided directory is already absolute and use it
    jenkins_home_absolute_path=${jenkins_home}
else
    # If no ./ or / at beginning, assume relative working directory and convert to absolute
    jenkins_home_absolute_path="$(pwd)/${jenkins_home}"
fi
jenkins_home=${jenkins_home_absolute_path}

# Checking if Jenkins home already exists to avoid overwriting configurations and breaking something
if [ ! -d "${jenkins_home}/jobs" ] || [[ ${override_action} == "recreate"   ]] || [[ ${override_action} == "destroy"   ]] || [[ ${override_action} == "fully-destroy"   ]]; then
    mkdir -p ${working_directory}
    mkdir -p ${jenkins_home}
    cp -R ./initial-setup/* ${jenkins_home}
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' 's;{{WORKING_DIRECTORY}};'${workdir_absolute_path}';g' ${jenkins_home}/nodes/local/config.xml
    else
        sed -i 's;{{WORKING_DIRECTORY}};'${workdir_absolute_path}';g' ${jenkins_home}/nodes/local/config.xml
    fi
fi

# Create shared directories for Vagrant and Terraform jobs
export shared_workspace_base_directory_path="${workdir_absolute_path}/workspace/shared_workspace"
export shared_workspace_directory_path="${shared_workspace_base_directory_path}/kx.as.code"

if [[ ! -L ${shared_workspace_directory_path} ]] && [[ ! -e ${shared_workspace_directory_path} ]]; then
  mkdir -p ${shared_workspace_base_directory_path}
  ln -s ../../../../../../../kx.as.code ${shared_workspace_base_directory_path}
fi

# Replace variable placeholders in Jenkins jobs
OLD_IFS=${IFS}
IFS=$'\n'
# Download tool for replacing mustache variables
if [[ ! -f ./mo ]]; then
    curl -sSL https://git.io/get-mo -o mo
    chmod +x ./mo
fi
initialSetupJobConfgXmlFiles=$(find jenkins_home/jobs -name "config.xml")
for initialSetupJobConfgXmlFile in ${initialSetupJobConfgXmlFiles}; do
    echo "[INFO] Replacing placeholders with values in ${initialSetupJobConfgXmlFile}"
    for i in {1..5}; do
        cat "${initialSetupJobConfgXmlFile}" | ./mo > "${initialSetupJobConfgXmlFile}_tmp"
        if [ -s "${initialSetupJobConfgXmlFile}_tmp" ]; then
            mv "${initialSetupJobConfgXmlFile}_tmp" "${initialSetupJobConfgXmlFile}"
            break
        else
            echo -e "${red}- [ERROR] Target config.xml file was empty after mustach replacement. Trying again${nc}"
        fi
    done
done
IFS=${OLD_IFS}

# Replace variables in main config xml file
for i in {1..5}; do
  echo "[INFO] Replacing placeholders with values in ${jenkins_home}/config.xml"
  cat "${jenkins_home}/config.xml" | ./mo > "${jenkins_home}/config.xml_tmp"
  if [ -s "${jenkins_home}/config.xml_tmp" ]; then
      mv "${jenkins_home}/config.xml_tmp" "${jenkins_home}/config.xml"
      break
  else
      echo -e "${red}- [ERROR] Target jenkins_home/config.xml file was empty after mustach replacement. Trying again${nc}"
  fi
done

# Start Jenkins
jenkinsContainer=$(docker ps -a -f "name=jenkins" -q)
if [ -z ${jenkinsContainer} ]; then
    "${dockerComposeBinary}" --env-file ./jenkins.env up -d
else
    docker start ${jenkinsContainer}
fi

# Downloading Jenkins CLI used for creating Jenkins credentials
echo -e "${orange}- [INFO] The next steps - downloading Jar files from Jenkins - might take a few minutes, as Jenkins needs to finish coming up before it will work${nc}"
echo -e "${blue}- [INFO] Waiting for jenkins-cli.jar to become available...${nc}"
while [[ ! -f ./jenkins-cli.jar ]]; do
    for i in {1..60}; do
        http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${jenkins_url}/jnlpJars/jenkins-cli.jar || true)
        if [[ ${http_code} == "200" ]]; then
            curl -s ${jenkins_url}/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
            break 2
        fi
        echo -e "${blue}- [INFO] Waiting for ${jenkins_url}/jnlpJars/jenkins-cli.jar [RC=${http_code}]${nc}"
        sleep 30
    done
done

# Check if Jenkins CLI is now available, if not exit script with error
if [[ ! -f ./jenkins-cli.jar ]]; then
    echo -e "${red}- [ERROR] Jenkins jenkins-cli.jar is still not available even after 30 minutes. It should not take this long for Jenkins to start... ${nc}"
    exit 1
fi

# Downloading Jenkins agent
echo -e "${blue}- [INFO] Waiting for agent.jar to become available...${nc}"
while [[ ! -f ./agent.jar ]]; do
    for i in {1..60}; do
        http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${jenkins_url}/jnlpJars/agent.jar || true)
        if [[ ${http_code} == "200" ]]; then
            curl -s ${jenkins_url}/jnlpJars/agent.jar -o agent.jar
            break 2
        fi
        echo -e "${blue}- [INFO] Waiting for ${jenkins_url}/jnlpJars/agent.jar [RC=${http_code}]${nc}"
        sleep 30
    done
done

# Check if agent.jar is now available, if not exit script with error
if [[ ! -f ./agent.jar ]]; then
    echo -e "${red}- [ERROR] Jenkins agent.jar is still not available even after 30 minutes. It should not take this long for Jenkins to start... ${nc}"
    exit 1
fi

# In case jars already existed, add an additional check to wait for RC200
echo -e "${blue}- [INFO] Waiting for Jenkins to be fully up before continuing...${nc}"
for i in {1..60}; do
    http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${jenkins_url}/view/Status/ || true)
    if [[ ${http_code} == "200" ]]; then
        echo -e "${green}- [INFO] Jenkins is up, continuing with setting up the build & deploy environment${nc}"
        break
    fi
    echo -e "${blue}- [INFO] Waiting for ${jenkins_url}/view/Status/ [RC=${http_code}]${nc}"
    sleep 30
done

# Check that docker-compose.yml is available on the current path
if [ ! -f ./docker-compose.yml ]; then
    echo -e "${red}- [ERROR] Cannot locate docker-compose.yml. Make sure you are in the right directory. Exiting${nc}"
    error="true"
fi

# Creating credentials in Jenkins
credentialXmlFiles=$(find jenkins_home/ -name "credential_*.xml")
for credentialXmlFile in ${credentialXmlFiles}; do
    echo "[INFO] Replacing placeholders with values in ${credentialXmlFile}"
    for i in {1..5}; do
        cat "${credentialXmlFile}" | ./mo > "${credentialXmlFile}_mo"
        if [ -s "${credentialXmlFile}_mo" ]; then
            cat "${credentialXmlFile}_mo" | "${javaBinary}" -jar jenkins-cli.jar -s ${jenkins_url} create-credentials-by-xml system::system::jenkins _ || true
            rm "${credentialXmlFile}_mo"
            break
        else
            echo -e "${red}- [ERROR] Target config.xml file was empty after mustach replacement. Trying again${nc}"
        fi
    done
done
IFS=${OLD_IFS}

# Checking if Vagrant is installed
vagrantInstalled=$(vagrant -v 2> /dev/null | grep -E "Vagrant.*([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${vagrantInstalled} ]]; then
    echo -e "${orange}- [WARN] Vagrant not installed or not reachable. Download vagrant from https://www.vagrantup.com/downloads.html and ensure it is reachable on your PATH."
    echo -e "         You will still be able to run packer builds, however, without Vagrant, you cannot bring up local machines${nc}"
fi

# Optional tool only needed for Vagrant VMWare profiles
ovftoolInstalled=$(ovftool --version 2> /dev/null | grep -E "VMware ovftool ([0-9]+)\.([0-9]+)\.([0-9]+)" || true)
if [[ -z ${ovftoolInstalled} ]]; then
    echo -e "${orange}- [WARN] Optional VMWare OVFTool not installed or not reachable. Download OVTOool from https://code.vmware.com/web/tool/4.4.0/ovf and ensure it is reachable on your PATH${nc}"
    warning="true"
fi

if [[ ${warning} == "true"  ]]; then
    echo -e "- [WARN] One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images"
    echo -e "Do you wish to continue anyway?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes)
                echo -e "[Yes], Continuing..."
                break
                ;;
            No)
                echo -e "[No], Exiting script..."
                exit 1
                ;;
        esac
    done
fi

if [[ ${error} == "true"  ]]; then
    echo -e "${error}- [ERROR] One or more components required to successfully build packer images for KX.AS.CODE were missing. Please resolve errors and try again"
    exit 1
fi

echo -e "${green}- [INFO] Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: ${jenkins_url}${nc}"

# Start Jenkins Agent
echo -e "${blue}- [INFO] Connecting the local agent to Jenkins...${nc}"
if [[ -n ${jnlp_secret}   ]]; then
    "${javaBinary}" -jar agent.jar -jnlpUrl ${jenkins_url}/computer/${agent_name}/slave-agent.jnlp -connectTo ${jenkins_host}:${jenkins_jnlp_port} -secret ${jnlp_secret} -workDir "${working_directory}"
else
    echo -e "${orange}- [INFO] jnlp_secret is not set. This is OK for a local setup. If you want to add it, you'll have to configure it manually after everything has started${nc}"
    "${javaBinary}" -jar agent.jar -jnlpUrl ${jenkins_url}/computer/${agent_name}/slave-agent.jnlp -workDir "${working_directory}"
fi
