#!/bin/bash

# Define ansi colours
red="\033[31m"
green="\033[32m"
orange="\033[33m"
blue="\033[94m"
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

# Determine OS this script is running on and set appropriate download links
case $(uname -s) in

    Linux)
      echo -e "${blue}- [INFO] Script running on Linux. Setting appropriate download links${nc}"
      dockerComposeInstallerUrl= "https://github.com/docker/compose/releases/download/${composeDownloadVersion}/docker-compose-Linux-x86_64"
      javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-linux-x64.tar.gz"
      ;;
    Darwin)
      echo -e "${blue}- [INFO] Script running on Darwin Setting appropriate download links${nc}"
      dockerComposeInstallerUrl="https://github.com/docker/compose/releases/download/${composeDownloadVersion}/docker-compose-Darwin-x86_64"
      javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-macosx-x64.tar.gz"
      ;;
    *)
      echo -e "${blue}- [INFO] Script running on Windows Setting appropriate download links${nc}"
      dockerComposeInstallerUrl="https://github.com/docker/compose/releases/download/${composeDownloadVersion}/docker-compose-Windows-x86_64.exe"
      javaInstallerUrl="https://d3pxv6yz143wms.cloudfront.net/${javaDownloadVersion}/amazon-corretto-${javaDownloadVersion}-windows-x64.zip"
      ;;
esac

echo "- [INFO] Set docker-compose download link to: ${dockerComposeInstallerUrl}${nc}"
echo "- [INFO] Set java download link to: ${javaInstallerUrl}${nc}"

# Check if Docker-Compose is installed
if [[ ! -f ./docker-compose ]] && [[ -z $(which docker-compose) ]]; then
  echo -e "${blue}- [INFO] Docker-compose is not installed or not reachable. Downloading from https://docs.docker.com/compose/install/${nc}"
    curl -o ./docker-compose ${dockerComposeInstallerUrl}
    chmod -L 755 ./docker-compose
    dockerComposeExecutable="./docker-compose"
elif [[ -f ./docker-compose ]]; then
  dockerComposeExecutable=./docker-compose
else
  dockerComposeExecutable=$(which docker-compose)
fi

# Check if correct version
dockerComposeVersion=$("${dockerComposeExecutable}" -v 2>/dev/null | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
minimalComposeVersion=1.25.0
if [[ "$(printf '%s\n' "${minimalComposeVersion}" "${dockerComposeVersion}" | sort -V | head -n1)" = "${dockerComposeVersion}" ]]; then
  echo -e "${blue}- [INFO] You are using an outdated docker-compose executable, which means --env-file option will not be present. Downloading updated version from https://docs.docker.com/compose/install/${nc}"
  curl -L -o ./docker-compose ${dockerComposeInstallerUrl}
  chmod 755 ./docker-compose
  dockerComposeExecutable="./docker-compose"
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
if [[ ! -f ./java ]]; then
  javaInstalled=$(java --version 2>/dev/null | head -1 | grep -E ".*([0-9]+)\.([0-9]+)\.([0-9]+).*")
  if [[ -z ${javaInstalled} ]]; then
    echo -e "${blue}- [INFO] Java not installed or not reachable. Will download Java from https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html${nc}"
    mkdir -p java
    base=${javaInstallerUrl%.*}
    ext=${javaInstallerUrl#$base.}
    if [[ "${ext}" == "gz" ]]; then
      curl -o amazon-corretto-11-x64-linux-jdk.tar.gz -L ${javaInstallerUrl}
      tar xvzf amazon-corretto-11-x64-linux-jdk.tar.gz -C ./java
    elif [[ "${ext}" == "zip" ]]; then
      curl -o amazon-corretto-11-x64-linux-jdk.zip -L ${javaInstallerUrl}
      unzip amazon-corretto-11-x64-linux-jdk.zip -d ./java
    fi
    javaBinary=$(find ./java/**/bin/ -executable -type f \( -name "java.*" ! -name "*.dll" \))
    "${javaBinary}" --version
    error="false"
  fi
fi

#whichJava=$(which java)
if [ -n "${whichJava}" ] ; then
  javaBinary=$(which java)
elif [ -f $(find ./java/**/bin/ -executable -type f \( -name "java.*" ! -name "*.dll" \)) ]; then
  export PATH=$PATH:$(pwd)/java/bin
  javaBinary=$(find ./java/**/bin/ -executable -type f \( -name "java.*" ! -name "*.dll" \))
else
  echo "Java not found and could not be downloaded/installed. Exiting"
  exit 1
fi



if [ -d ${JENKINS_HOME} ]; then
  echo -e "${blue}- [INFO] ${JENKINS_HOME} already exists. Will skip Jenkins setup. Delete or rename ${JENKINS_HOME} if you want to re-install Jenkins${nc}"
fi

dockerMachineEnvironment=$(which docker-machine)
if [[ $? = 1 ]]; then 
  echo -e "${blue}- [INFO] Not a docker-machine environment, setting docker host to localhost${nc}"
  JENKINS_HOST=localhost
  JENKINS_URL=http://${JENKINS_HOST}:${JENKINS_SERVER_PORT}
else
  echo -e "${blue}- [INFO] Jenkins is running on docker-machine, setting docker host to 192.168.99.100${nc}"
  JENKINS_HOST=192.168.99.100
  JENKINS_URL=http://${JENKINS_HOST}:${JENKINS_SERVER_PORT}
fi

if [ ! -d ${JENKINS_HOME} ]; then

  docker build -t ${KX_JENKINS_IMAGE} ./initial-setup

  mkdir -p ${WORKING_DIRECTORY}
  mkdir -p ${JENKINS_HOME}

  cp -R ./initial-setup/* ${JENKINS_HOME}

  sed -i 's;{{WORKING_DIRECTORY}};'${WORKING_DIRECTORY}';g' ${JENKINS_HOME}/nodes/local/config.xml

fi

jenkinsContainer=$(docker ps -a -f "name=jenkins" -q)
if [ -z ${jenkinsContainer} ]; then
        "${dockerComposeExecutable}" --env-file ./jenkins.env up -d
else
        docker start ${jenkinsContainer}
fi

# Downloading Jenkins CLI used for creating Jenkins credentials
echo -e "${orange}- [INFO] The next steps - downloading Jar files - might take a couple of minutes, as Jenkins needs to finish coming up before it will work${nc}"
echo -e "${blue}- [INFO] Waiting for jenkins-cli.jar to become available...${nc}"
timeout --foreground -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' '${JENKINS_URL}'/jnlpJars/jenkins-cli.jar)" != "200" ]]; do \
  echo -e "'${blue}'- [INFO] Waiting for '${JENKINS_URL}'/jnlpJars/jenkins-cli.jar'${nc}'"; sleep 5; done'

if [ ! -f ./jenkins-cli.jar ]; then
  curl ${JENKINS_URL}/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
fi

# Downloading Jenkins agent
echo -e "${blue}- [INFO] Waiting for agent.jar to become available...${nc}"
timeout --foreground -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' '${JENKINS_URL}'/jnlpJars/agent.jar)" != "200" ]]; do \
  echo -e "'${blue}'- [INFO] Waiting for '${JENKINS_URL}'/jnlpJars/agent.jar'${nc}'"; sleep 5; done'

if [ ! -f ./agent.jar ]; then
  curl ${JENKINS_URL}/jnlpJars/agent.jar -o agent.jar
fi

# Check that docker-compose.yml is available on the current path
if [ ! -f ./docker-compose.yml ]; then
  echo -e "${red}- [ERROR] Cannot locate docker-compose.yml. Make sure you are in the right directory. Exiting${nc}"
  error="true"
fi

# Create Github Credentials
if [[ -n ${GITHUB_USERNAME} ]] && [[ -n ${GITHUB_PASSWORD} ]]; then
  cat initial-setup/credential_github.xml | sed 's/{{GITHUB_USERNAME}}/'${GITHUB_USERNAME}'/g' | sed 's/{{GITHUB_PASSWORD}}/'${GITHUB_PASSWORD}'/g' | java -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${red}- [ERROR] GITHUB credential must be set in jenkins.env, else the build will fail. Please set and try again${nc}"
  error="true"
fi

# Creating Openstack credentials in Jenkins
if [[ -n ${OPENSTACK_USERNAME}  ]] && [[ -n ${OPENSTACK_PASSWORD} ]]; then
  cat initial-setup/credential_openstack_packer.xml  | sed 's/{{OPENSTACK_USERNAME}}/'${OPENSTACK_USERNAME}'/g' | sed 's/{{OPENSTACK_PASSWORD}}/'${OPENSTACK_PASSWORD}'/g' |  java -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${orange}- [WARN] Openstack credentials not set in jenkins.env. Dummy value will be used for user and password. You can update these manually later in Jenkins, or updated jenkins.env and launch this script again${nc}"
fi

# Creating AWS credentials in Jenkins
if [[ -n ${PACKER_AWS_ACCESS_KEY} ]] && [[ -n ${PACKER_AWS_ACCESS_SECRET} ]]; then
  cat initial-setup/credential_aws_packer.xml  | sed 's/{{PACKER_AWS_ACCESS_KEY}}/'${PACKER_AWS_ACCESS_KEY}'/g' | sed 's/{{PACKER_AWS_ACCESS_SECRET}}/'${PACKER_AWS_ACCESS_SECRET}'/g' |  java -jar jenkins-cli.jar -s ${JENKINS_URL} create-credentials-by-xml system::system::jenkins _
else
  echo -e "${orange}- [WARN] AWS credentials not set in jenkins.env. Dummy value will be used for user and password. You can update these manually later in Jenkins, or updated jenkins.env and launch this script again${nc}"
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
if [[ -n "${JNLP_SECRET}" ]]; then
  "${javaBinary}" -jar agent.jar -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp -connectTo ${JENKINS_HOST}:${JENKINS_JNLP_PORT} -secret ${JNLP_SECRET} -workDir "${WORKING_DIRECTORY}"
else
  echo -e "- [INFO] JNLP_SECRET is not set. This is OK for a local setup. Will try to connect without it. If this was meant, then OK, otherwise add the value to jenkins.env and try again"
  "${javaBinary}" -jar agent.jar -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp -workDir "${WORKING_DIRECTORY}"
fi
