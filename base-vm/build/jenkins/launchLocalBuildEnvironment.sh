#!/bin/bash
dockerMachineEnvironment=$(which docker-machine)
if [[ $? = 1 ]]; then 
  echo "Not a docker-machine environment, setting docker host to localhost"
  JENKINS_URL=http://localhost:8080

else
  echo "Jenkins is running on docker-machine, setting docker host to 192.168.99.100"
  JENKINS_URL=http://192.168.99.100:8080 # You might need to change this. This is the default docker-machine IP

fi

WORKING_DIRECTORY=/Users/akshay.u.gupta/Documents/jenkins_remote
mkdir -p ${WORKING_DIRECTORY}
JNLP_SECRET=772229e2c975d4bb30d474da488a2a5956bc04a0e35108d0c9a5e3be7a807e51

# Check that docker-compose.yml is available on the current path
if [ ! -f ./docker-compose.yml ]; then
  echo "- [ERROR] Cannot locate docker-compose.yml. Make sure you are in the right directory. Exiting"
  error="true"
fi

# Checking if Vagrant is installed
vagrantInstalled=$(vagrant -v 2>/dev/null | grep -E "Vagrant.*([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${vagrantInstalled} ]]; then
  echo "- [ERROR] Vagrant not installed or not reachable. Download packer from https://www.vagrantup.com/downloads.html and ensure it is reachable on your PATH"
  error="true"
fi

# Checking if Packer is installed
packerInstalled=$(packer -v 2>/dev/null | grep -E "([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${vagrantInstalled} ]]; then
  echo "- [ERROR] Packer not installed or not reachable. Download packer from https://www.packer.io/downloads and ensure it is reachable on your PATH"
  error="true"
fi

# Check if Docker is installed
dockerComposeInstalled=$(docker-compose -v 2>/dev/null | grep -E "docker-compose version ([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${dockerComposeInstalled} ]]; then
  echo "- [ERROR] Docker-Compose not installed or not reachable. See https://docs.docker.com/compose/install/ for installation guidelines and ensure it is reachable on your PATH"
  error="true"
fi

# Check if Docker-Compose is installed
dockerInstalled=$(docker -v 2>/dev/null | grep -E "Docker version ([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${dockerInstalled} ]]; then
  echo "- [ERROR] Docker not installed or not reachable. Read the guide for you distribution for HOW-TO install docker. Also, check your user has permissions to access Docker and that is is reachable on the PATH"
  error="true"
fi

# Check if Java is installed
if [[ ! -f java/bin/java ]]; then
  javaInstalled=$(java --version 2>/dev/null | head -1 | grep -E ".*([0-9]+)\.([0-9]+)\.([0-9]+).*")
  if [[ -z ${javaInstalled} ]]; then
    echo "- [ERROR] Java not installed or not reachable. Download Java from https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html and ensure it is reachable on your PATH"
    wget https://corretto.aws/downloads/latest/amazon-corretto-11-x64-linux-jdk.tar.gz
    mkdir java
    tar xvzf amazon-corretto-11-x64-linux-jdk.tar.gz --strip-components=1 -C ./java
    javaBinary=./java/bin/java
    error="true"
  fi
fi

ovftoolInstalled=$(ovftool --version 2>/dev/null | grep -E "VMware ovftool ([0-9]+)\.([0-9]+)\.([0-9]+)")
if [[ -z ${ovftoolInstalled} ]]; then
  echo "- [WARNING] OVFTool not installed or not reachable. Download OVTOool from https://code.vmware.com/web/tool/4.4.0/ovf and ensure it is reachable on your PATH"
  warning="true"
fi

if [[ "${warning}" = "true" ]]; then
  echo "One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images"
  echo "Do you wish to continue anyway?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) echo "[Yes], Continuing..."; break;;
          No ) echo "[No], Exiting script...";exit 1;;
      esac
  done
fi

if [[ "${error}" = "true" ]]; then
  echo "One or more components REQUIRED to successfully build packer images for KX.AS.CODE were missing. Please resolve ERRORs and try again"
  exit 1
fi

jenkinsContainerExists=$(docker ps -a -f "name=jenkins" -q)
if [ -z ${jenkinsContainerExists} ]; then
	docker-compose up -d
else
	docker-compose start jenkins
fi

echo "Waiting for agent.jar to become available...(URL ${JENKINS_URL})"

timeout -s TERM 60 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' '${JENKINS_URL}/jnlpJars/agent.jar')" != "200" ]]; do \
  echo "Waiting for '${JENKINS_URL}/jnlpJars/agent.jar'"; sleep 5; done'

if [ ! -f ./agent.jar ]; then
  curl ${JENKINS_URL}/jnlpJars/agent.jar -o agent.jar
fi

java -jar agent.jar -jnlpUrl ${JENKINS_URL}/computer/Local/slave-agent.jnlp -secret ${JNLP_SECRET} -workDir "${WORKING_DIRECTORY}"
