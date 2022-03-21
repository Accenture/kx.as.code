#!/bin/bash -x
set -euo pipefail

export bitwardenHomeDir=/opt/bitwarden
export bitwardenDataDir=${bitwardenHomeDir}/bwdata

# Install Expect
/usr/bin/sudo apt-get install -y expect

# Create Bitwarden user
/usr/bin/sudo id -u bitwarden &>/dev/null || adduser bitwarden

# Add groups to Bitwarden user
/usr/bin/sudo usermod -aG docker bitwarden

# Create Bitwarden data directrory
/usr/bin/sudo mkdir -p ${bitwardenDataDir}/ssl/${componentName}.${baseDomain}

# Copy self signed certificates to Bitwarden data directory
/usr/bin/sudo cp ${installationWorkspace}/kx-certs/* ${bitwardenDataDir}/ssl/${componentName}.${baseDomain}

# Create Bitwarden config file from template
envsubst < ${installComponentDirectory}/config_template.yml > ${bitwardenDataDir}/config.yml

# Correct directory permissions
/usr/bin/sudo chmod -R 700 ${bitwardenHomeDir}
/usr/bin/sudo chown -R bitwarden:bitwarden ${bitwardenHomeDir}

# Download Bitwarden install script
/usr/bin/sudo curl -Lso ${bitwardenHomeDir}/bitwarden.sh https://go.btwrdn.co/bw-sh \
    && /usr/bin/sudo chmod 700 ${bitwardenHomeDir}/bitwarden.sh

# Execute Bitwarden install script
cd ${bitwardenHomeDir}


#########################################################################
# The code below is from Bitwarden's bitwarden.sh and run.sh scripts.
# Variable names kept the same for easier updating in future.
#########################################################################

COREVERSION="1.42.3"
WEBVERSION="2.22.3"
OUTPUT_DIR=${bitwardenDataDir}
ENV_DIR="$OUTPUT_DIR/env"
DOCKER_DIR="$OUTPUT_DIR/docker"
USER="bitwarden"
LUID="LOCAL_UID=`id -u $USER`"
LGID="LOCAL_GID=`id -g $USER`"
OS="lin"
mkdir -p $ENV_DIR
echo $LUID >$ENV_DIR/uid.env
echo $LGID >>$ENV_DIR/uid.env

# Answers without Bitwarden install script prompts
DOMAIN="${componentName}.${baseDomain}"
LETS_ENCRYPT="n"
DATABASE="vault"

echo "bitwarden.sh version $COREVERSION"

# Create Bitwarden Base Directories
mkdir -p "${OUTPUT_DIR}/core/attachments"
mkdir -p "${OUTPUT_DIR}/logs/admin"
mkdir -p "${OUTPUT_DIR}/logs/api"
mkdir -p "${OUTPUT_DIR}/logs/events"
mkdir -p "${OUTPUT_DIR}/logs/icons"
mkdir -p "${OUTPUT_DIR}/logs/identity"
mkdir -p "${OUTPUT_DIR}/logs/mssql"
mkdir -p "${OUTPUT_DIR}/logs/nginx"
mkdir -p "${OUTPUT_DIR}/logs/notifications"
mkdir -p "${OUTPUT_DIR}/logs/sso"
mkdir -p "${OUTPUT_DIR}/logs/portal"
mkdir -p "${OUTPUT_DIR}/mssql/backups"
mkdir -p "${OUTPUT_DIR}/mssql/data"
/usr/bin/sudo chown -R bitwarden:bitwarden ${OUTPUT_DIR}

# Setup Bitwarden
docker pull bitwarden/setup:$COREVERSION
docker run --rm --name setup -v $OUTPUT_DIR:/bitwarden \
        --env-file $ENV_DIR/uid.env bitwarden/setup:$COREVERSION \
        dotnet Setup.dll -install 1 -domain $DOMAIN -letsencrypt $LETS_ENCRYPT -os $OS \
        -corev $COREVERSION -webv $WEBVERSION -dbname "$DATABASE"

# Start Bitwarden
export COMPOSE_FILE="$DOCKER_DIR/docker-compose.yml"
export COMPOSE_HTTP_TIMEOUT="300"
docker-compose up -d
