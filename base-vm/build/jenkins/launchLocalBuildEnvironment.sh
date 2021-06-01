#!/bin/bash

# Define ansi colours
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[36m"
nc="\033[0m" # No Color

if [ ! -f ./jenkins.env ]; then
  echo -e "${red}- [ERROR] Please create the jenkins.env file in the base-vm/build/jenkins folder by copying the template (jenkins.env.template --> jenkins.env), and adding the details"
  echo -e "        Additionally, you must cd into the base-vm/build/jenkins directory before launching this script${nc}"
  exit 1
fi

# Settings that will be used for provisioning Jenkins, including credentials etc
source ./jenkins.env

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
echo "${dockerComposeBinary}"
if [[ -z "${dockerComposeBinary}" ]]; then
    echo -e "${blue}- [INFO] Docker-compose is not installed or not reachable. Downloading from https://docs.docker.com/compose/install/${nc}"
    curl -L -s -o ./docker-compose ${dockerComposeInstallerUrl}
    chmod 755 ./docker-compose
    if [[ "os" == "windows" ]]; then
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
echo "${jqBinary}"
if [[ -z "${jqBinary}" ]]; then
    echo -e "${blue}- [INFO] jq is not installed or not reachable. Downloading from https://github.com/stedolan/jq/releases/download/${nc}"
    curl -L -s -o ./jq ${jqInstallerUrl}
    chmod 755 ./jq
    if [[ "os" == "windows" ]]; then
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
dockerComposeVersion=$("${dockerComposeBinary}" -v 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
minimalComposeVersion=1.25.0
if [[ "$(printf '%s\n' "${minimalComposeVersion}" "${dockerComposeVersion}" | sort -V | head -n1)" = "${dockerComposeVersion}" ]]; then
  echo -e "${blue}- [INFO] You are using an outdated docker-compose executable, which means --env-file option will not be present. Downloading updated version from https://docs.docker.com/compose/install/${nc}"
  curl -L -s -o ./docker-compose ${dockerComposeInstallerUrl}
  chmod 755 ./docker-compose
  dockerComposeBinary="./docker-compose"
else
  echo -e "${green}- [INFO] All good with docker-compose. Proceeding...${nc}"
fi

# Check if Docker is installed
dockerInstalled=$(docker -v 2>/dev/null | grep -E "Docker version ([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${dockerInstalled} ]]; then
  echo -e "${red}- [ERROR] Docker not installed or not reachable. Read the guide for you distribution for how to install docker. Also, check your user has permissions to access Docker and that is is reachable on the PATH${nc}"
  error="true"
fi

# Check if Java is installed
#javaBinary=${$(which java | sed 's;java not found;;g'):-$(find ./java/**/bin/ -type f \( -name "java" -or -name "java.exe" ! -name "*.dll" \))}
javaBinaryWhich=$(which java | sed 's;java not found;;g')
javaBinaryLocal=$(find ./java/**/bin/ -type f \( -name "java" -or -name "java.exe" ! -name "*.dll" \))
javaBinary=${javaBinaryWhich:-${javaBinaryLocal}}
echo ${javaBinary}
if [[ -z "${javaBinary}" ]]; then
  javaInstalled=$(${javaBinary} --version 2>/dev/null | head -1 | grep -E ".*([0-9]+)\.([0-9]+)\.([0-9]+).*")
  if [[ -z ${javaInstalled} ]]; then
    echo -e "${blue}- [INFO] Java not installed or not reachable. Will download Java from https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html${nc}"
    mkdir -p java
    base=${javaInstallerUrl%.*}
    ext=${javaInstallerUrl#$base.}
    if [[ "${ext}" == "gz" ]]; then
      curl -s -o amazon-corretto-11-x64-linux-jdk.tar.gz -L ${javaInstallerUrl}
      tar tzf amazon-corretto-11-x64-linux-jdk.tar.gz 1>/dev/null 2>/dev/null
      if [[ $? -ne 0 ]]; then
        echo -e "${red}- [ERROR] The downloaded Java compressed tar.gz file does not seem to be valid. Please check your internet connection and try again${nc}"
        exit 1
      fi
      echo -e "${blue}- [INFO] The downloaded Java compressed tar.gz file seems to be complete. Extracting files and continuing${nc}"
      tar xvzf amazon-corretto-11-x64-linux-jdk.tar.gz -C ./java
    elif [[ "${ext}" == "zip" ]]; then
      curl -s -o amazon-corretto-11-x64-linux-jdk.zip -L ${javaInstallerUrl}
      unzip -t amazon-corretto-11-x64-linux-jdk.zip
      if [[ $? -ne 0 ]]; then
        echo -e "${red}- [ERROR] The downloaded Java compressed zip file does not seem to be valid. Please check your internet connection and try again${nc}"
        exit 1
      fi
      echo -e "${blue}- [INFO] The downloaded Java compressed zip file seems to be complete. Extracting files and continuing${nc}"
      unzip amazon-corretto-11-x64-linux-jdk.zip -d ./java
    fi
    javaBinary=$(find ./java/**/bin/ -type f \( -name "java" -or -name "java.exe" ! -name "*.dll" \))
    if [[ -z ${javaBinary} ]]; then
      echo -e "${red}[ERROR] Java not found and could not be downloaded/installed. Exiting${nc}"
      exit 1
    fi
    error="false"
  fi
fi

if [ -d ${JENKINS_HOME} ]; then
  echo -e "${blue}- [INFO] ${JENKINS_HOME} already exists. Will skip Jenkins setup. Delete or rename ${JENKINS_HOME} if you want to re-install Jenkins${nc}"
fi

# Checking if running on docker-machine to set correct Jenkins URL
if [[ $(docker -D info --format '{{json .}}' | ${jqBinary} -r '.KernelVersion') =~ boot2docker ]]; then
  echo -e "${blue}- [INFO] Jenkins is running on docker-machine, setting docker host to 192.168.99.100${nc}"
  JENKINS_HOST=192.168.99.100
  JENKINS_URL=http://${JENKINS_HOST}:${JENKINS_SERVER_PORT}
else
  echo -e "${blue}- [INFO] Not a docker-machine environment, setting docker host to localhost${nc}"
  JENKINS_HOST=localhost
  JENKINS_URL=http://${JENKINS_HOST}:${JENKINS_SERVER_PORT}
fi

#Building Docker Image if it does not exist
if [[ -z $(docker images ${KX_JENKINS_IMAGE} -q) ]]; then
  echo -e "${blue}- [INFO] Image ${KX_JENKINS_IMAGE} not present on this machine. Building...${nc}"
  docker build -t ${KX_JENKINS_IMAGE} ./initial-setup
  if [[ $? -ne 0 ]]; then
    echo -e "${red}- [INFO] Build of image ${KX_JENKINS_IMAGE} failed${nc}"
  else
    echo -e "${green}- [INFO] Build of image ${KX_JENKINS_IMAGE} completed successfully${nc}"
  fi
fi

# Checking if Jenkins home already exists to avoid overwriting configurations and breaking something
if [ ! -d ${JENKINS_HOME} ]; then
  mkdir -p ${WORKING_DIRECTORY}
  mkdir -p ${JENKINS_HOME}
  cp -R ./initial-setup/* ${JENKINS_HOME}
  firstTwoChars=$(echo "${WORKING_DIRECTORY}" | head -c2)
  firstChar=$(echo "${WORKING_DIRECTORY}" | head -c1)
  if [[ "${firstTwoChars}" == "./" ]]; then
    # if workspace directory starts with ./, convert relative directory to absolute
    WORKDIR_ABSOLUTE_PATH=$(pwd)/$(echo ${WORKING_DIRECTORY} | sed 's;\./;;g')
  elif [[ "${firstChar}" != "/" ]]; then
    # If no ./ or / at beginning, assume relative working directory and convert to absolute
    WORKDIR_ABSOLUTE_PATH="$(pwd)/${WORKING_DIRECTORY}"
  else
    # If / at start, assume provided directory is already absolute and use it
    WORKDIR_ABSOLUTE_PATH=${WORKING_DIRECTORY}
  fi
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' 's;{{WORKING_DIRECTORY}};'${WORKDIR_ABSOLUTE_PATH}';g' ${JENKINS_HOME}/nodes/local/config.xml
  else
    sed -i 's;{{WORKING_DIRECTORY}};'${WORKDIR_ABSOLUTE_PATH}';g' ${JENKINS_HOME}/nodes/local/config.xml
  fi
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
for initialSetupJobConfgXmlFile in ${initialSetupJobConfgXmlFiles}
do
  echo "[INFO] Replacing placeholders with values in ${initialSetupJobConfgXmlFile}"
  for i in {1..5}
    do
    cat "${initialSetupJobConfgXmlFile}" | ./mo | tee "${initialSetupJobConfgXmlFile}_tmp"
    if [ -s "${initialSetupJobConfgXmlFile}_tmp" ]
    then
       mv "${initialSetupJobConfgXmlFile}_tmp" "${initialSetupJobConfgXmlFile}"
       break
    else
       echo -e "${red}- [ERROR] Target config.xml file was empty after mustach replacement. Trying again${nc}"
    fi
  done
done
IFS=${OLD_IFS}

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
while [[ ! -f ./jenkins-cli.jar ]]
do
  for i in {1..60}
  do
    http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${JENKINS_URL}/jnlpJars/jenkins-cli.jar)
    if [[ "${http_code}" == "200" ]]; then
      curl -s ${JENKINS_URL}/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
      break 2
    fi
    echo -e "${blue}- [INFO] Waiting for ${JENKINS_URL}/jnlpJars/jenkins-cli.jar [RC=${http_code}]${nc}"
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
while [[ ! -f ./agent.jar ]]
do
  for i in {1..60}
  do
    http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${JENKINS_URL}/jnlpJars/agent.jar)
    if [[ "${http_code}" == "200" ]]; then
      curl -s ${JENKINS_URL}/jnlpJars/agent.jar -o agent.jar
      break 2
    fi
    echo -e "${blue}- [INFO] Waiting for ${JENKINS_URL}/jnlpJars/agent.jar [RC=${http_code}]${nc}"
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
for i in {1..60}
do
  http_code=$(curl -s -o /dev/null -L -w '%{http_code}' ${JENKINS_URL}/view/Status/)
  if [[ "${http_code}" == "200" ]]; then
    echo -e "${green}- [INFO] Jenkins is up, continuing with setting up the build & deploy environment${nc}"
    break
  fi
  echo -e "${blue}- [INFO] Waiting for ${JENKINS_URL}/view/Status/ [RC=${http_code}]${nc}"
  sleep 30
done

# Check that docker-compose.yml is available on the current path
if [ ! -f ./docker-compose.yml ]; then
  echo -e "${red}- [ERROR] Cannot locate docker-compose.yml. Make sure you are in the right directory. Exiting${nc}"
  error="true"
fi

# Create Github Credentials
if [[ -n ${GITHUB_USERNAME} ]] && [[ -n ${GITHUB_PASSWORD} ]]; then
  cat initial-setup/credential_github.xml | sed 's/{{GITHUB_USERNAME}}/'${GITHUB_USERNAME}'/g' | sed 's/{{GITHUB_PASSWORD}}/'${GITHUB_PASSWORD}'/g' | "${javaBinary}" -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${red}- [ERROR] GITHUB credential must be set in jenkins.env, else the build will fail. Please set and try again${nc}"
  error="true"
fi

# Creating Openstack Packer credentials in Jenkins
if [[ -n ${OPENSTACK_PACKER_USERNAME}  ]] && [[ -n ${OPENSTACK_PACKER_PASSWORD} ]]; then
  cat initial-setup/credential_openstack_packer.xml  | sed 's/{{OPENSTACK_PACKER_USERNAME}}/'${OPENSTACK_PACKER_USERNAME}'/g' | sed 's/{{OPENSTACK_PACKER_PASSWORD}}/'${OPENSTACK_PACKER_PASSWORD}'/g' |  "${javaBinary}" -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${orange}- [WARN] Openstack Packer credentials not set in jenkins.env. Dummy value will be used for user and password. You can update these manually later in Jenkins, or updated jenkins.env and launch this script again${nc}"
fi

# Creating AWS Packer credentials in Jenkins
if [[ -n ${PACKER_AWS_PACKER_ACCESS_KEY} ]] && [[ -n ${PACKER_AWS_PACKER_ACCESS_SECRET} ]]; then
  cat initial-setup/credential_aws_packer.xml  | sed 's/{{PACKER_AWS_PACKER_ACCESS_KEY}}/'${PACKER_AWS_PACKER_ACCESS_KEY}'/g' | sed 's/{{PACKER_AWS_PACKER_ACCESS_SECRET}}/'${PACKER_AWS_PACKER_ACCESS_SECRET}'/g' |  "${javaBinary}" -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${orange}- [WARN] AWS Packer credentials not set in jenkins.env. Dummy value will be used for user and password. You can update these manually later in Jenkins, or updated jenkins.env and launch this script again${nc}"
fi

# Creating Openstack Terraform credentials in Jenkins
if [[ -n ${OPENSTACK_TERRAFORM_USERNAME}  ]] && [[ -n ${OPENSTACK_TERRAFORM_PASSWORD} ]]; then
  cat initial-setup/credential_openstack_terraform.xml  | sed 's/{{OPENSTACK_TERRAFORM_USERNAME}}/'${OPENSTACK_TERRAFORM_USERNAME}'/g' | sed 's/{{OPENSTACK_TERRAFORM_PASSWORD}}/'${OPENSTACK_TERRAFORM_PASSWORD}'/g' |  "${javaBinary}" -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${orange}- [WARN] Openstack Terraform credentials not set in jenkins.env. Dummy value will be used for user and password. You can update these manually later in Jenkins, or updated jenkins.env and launch this script again${nc}"
fi

# Creating AWS Terraform credentials in Jenkins
if [[ -n ${PACKER_AWS_TERRAFORM_ACCESS_KEY} ]] && [[ -n ${PACKER_AWS_TERRAFORM_ACCESS_SECRET} ]]; then
  cat initial-setup/credential_aws_terraform.xml  | sed 's/{{PACKER_AWS_TERRAFORM_ACCESS_KEY}}/'${PACKER_AWS_TERRAFORM_ACCESS_KEY}'/g' | sed 's/{{PACKER_AWS_TERRAFORM_ACCESS_SECRET}}/'${PACKER_AWS_TERRAFORM_ACCESS_SECRET}'/g' |  "${javaBinary}" -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${orange}- [WARN] AWS Terraform credentials not set in jenkins.env. Dummy value will be used for user and password. You can update these manually later in Jenkins, or updated jenkins.env and launch this script again${nc}"
fi

# Checking if Vagrant is installed
vagrantInstalled=$(vagrant -v 2>/dev/null | grep -E "Vagrant.*([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${vagrantInstalled} ]]; then
  echo -e "${orange}- [WARN] Vagrant not installed or not reachable. Download vagrant from https://www.vagrantup.com/downloads.html and ensure it is reachable on your PATH."
  echo -e "         You will still be able to run packer builds, however, without Vagrant, you cannot bring up local machines${nc}"
fi

# Optional tool only needed for Vagrant VMWare profiles
ovftoolInstalled=$(ovftool --version 2>/dev/null | grep -E "VMware ovftool ([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${ovftoolInstalled} ]]; then
  echo -e "${orange}- [WARN] Optional VMWare OVFTool not installed or not reachable. Download OVTOool from https://code.vmware.com/web/tool/4.4.0/ovf and ensure it is reachable on your PATH${nc}"
  warning="true"
fi

if [[ "${warning}" = "true" ]]; then
  echo -e "One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images"
  echo -e "Do you wish to continue anyway?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) echo -e "[Yes], Continuing..."; break;;
          No ) echo -e "[No], Exiting script...";exit 1;;
      esac
  done
fi

if [[ "${error}" = "true" ]]; then
  echo -e "${error}One or more components required to successfully build packer images for KX.AS.CODE were missing. Please resolve errors and try again"
  exit 1
fi

echo -e "${green}Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: ${JENKINS_URL}${nc}"

# Start Jenkins Agent
echo -e "${blue}- [INFO] Connecting the local agent to Jenkins...${nc}"
if [[ -n "${JNLP_SECRET}" ]]; then
  "${javaBinary}" -jar agent.jar -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp -connectTo ${JENKINS_HOST}:${JENKINS_JNLP_PORT} -secret ${JNLP_SECRET} -workDir "${WORKING_DIRECTORY}"
else
  echo -e "${orange}- [INFO] JNLP_SECRET is not set. This is OK for a local setup. Will try to connect without it. If this was meant, then OK, otherwise add the value to jenkins.env and try again${nc}"
  "${javaBinary}" -jar agent.jar -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp -workDir "${WORKING_DIRECTORY}"
fi
