#!/bin/bash
set -euo pipefail

# Get global base variables from globalVariables.json
source /usr/share/kx.as.code/git/kx.as.code/auto-setup/functions/getGlobalVariables.sh # source function
getGlobalVariables # execute function

# Load Central Functions
functionsLocation="${autoSetupHome}/functions"
for function in $(find ${functionsLocation} -name "*.sh")
do
  source ${function}
  echo "Loaded function $(cat ${function} | grep '()' | sed 's/{//g')"
done

# Declare variables to avoid ubound errors
export retries="0"
export action=""
export componentName=""
export componentInstallationFolder=""
export payload=""
export dockerHubUsername=""
export dockerHubPassword=""
export dockerHubEmail=""

# Get and export versions - currently versions for Kubernetes and KX.AS.CODE
getVersions

# Install envhandlebars needed to do moustache variable replacements
installEnvhandlebars

# Import error handler
source "${sharedGitHome}/kx.as.code/base-vm/dependencies/shell-core/base/trap.bash"

# Check profile-config.json file is present before starting script
waitForFile ${installationWorkspace}/profile-config.json

cd ${installationWorkspace}

# Copy metadata.json to installation workspace if it doesn't exist
if [[ ! -f ${installationWorkspace}/metadata.json ]]; then
    cp ${autoSetupHome}/metadata.json ${installationWorkspace}
fi

# Wait for last provisioning shell action to complete before proceeding to next steps
# such as changing network settings and merging action files
waitForFile ${installationWorkspace}/gogogo

# Copy actionQueues.json to installation workspace if it doesn't exist
# and merge with user aq* files if present
if [[ ! -f ${installationWorkspace}/actionQueues.json ]]; then
  cp ${autoSetupHome}/actionQueues.json ${installationWorkspace}/
  populateActionQueue
fi

# Get network configuration - specifically which NIC to use or exclude
getNetworkConfiguration

# Source profile-config.json set for this KX.AS.CODE installation
getProfileConfiguration

# Configure network, as well as Bind9 and HTTP(S) Proxy settings
configureNetwork

# Configure Keyboard language and layout settings
configureKeyboardSettings

# Wait for RabbitMQ web service to be reachable before continuing
timeout -s TERM 600 bash -c 'while [[ "$(curl -s -o /dev/null -L -w ''%{http_code}'' http://127.0.0.1:15672/cli/rabbitmqadmin)" != "200" ]]; do \
            echo "Waiting for http://127.0.0.1:15672/cli/rabbitmqadmin"; sleep 5; done'

# Check if rabbitmqadmin is installed
checkRabbitMq

# Create RabbitMQ Exchange if it does not exist
createRabbitMQExchange

# Create RabbitMQ Queues if they do not exist
createRabbitMQQueues

# Create RabbitMQ Bindings if they do not exist
createRabbitMQWorkflowBindings

# Get first and last elements from Core install Queue
lastCoreElementToInstall=$(cat ${installationWorkspace}/actionQueues.json | jq -r 'last(.action_queues.install[] | select(.install_folder=="core")) | .name')
if [[ "${lastCoreElementToInstall}" == "null" ]]; then
    lastCoreElementToInstall=$(cat ${installationWorkspace}/actionQueues.json | jq -r 'last(.state.processed[] | select(.install_folder=="core")) | .name')
fi
firstCoreElementToInstall=$(cat ${installationWorkspace}/actionQueues.json | jq -r 'first(.action_queues.install[] | select(.install_folder=="core")) | .name')
if [[ "${lastCoreElementToInstall}" == "null" ]]; then
    firstCoreElementToInstall=$(cat ${installationWorkspace}/actionQueues.json | jq -r 'first(.state.processed[] | select(.install_folder=="core")) | .name')
fi
count=0

# Populate pending queue on first start with default core components
defaultComponentsToInstall=$(cat ${installationWorkspace}/actionQueues.json | jq -r '.action_queues.install[].name')
for componentName in ${defaultComponentsToInstall}; do
    payload=$(cat ${installationWorkspace}/actionQueues.json | jq -c '.action_queues.install[] | select(.name=="'${componentName}'") | {install_folder:.install_folder,"name":.name,"action":"install","retries":"0"}')
    echo "Pending payload: ${payload}"
    rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''

    # Get slot number to add installed app to JSON array
    arrayLength=$(cat ${installationWorkspace}/actionQueues.json | jq -r '.state.processed[].name' | wc -l)
    if [[ -z ${arrayLength} ]]; then
        arrayLength=0
    fi
    # Add component to state.processed array in actionQueue.json
    cat ${installationWorkspace}/actionQueues.json | jq '.state.processed['${arrayLength}'] |= . + '"${payload}"'' | tee ${installationWorkspace}/actionQueues.json.tmp
    mv ${installationWorkspace}/actionQueues.json.tmp ${installationWorkspace}/actionQueues.json
    # Remove component from installation array as added to processed array in actionQueue.json
    cat ${installationWorkspace}/actionQueues.json | jq 'del(.action_queues.install[] | select(.name=="'${componentName}'"))' | tee ${installationWorkspace}/actionQueues.json.tmp
    mv ${installationWorkspace}/actionQueues.json.tmp ${installationWorkspace}/actionQueues.json
    sleep 1
done

# Set tries to 0. If an install failed and the retry flag is set to true for that component in metadata.json, attempts will be made to retry up to 3 times
retries=0
logRc=0
rc=0

# Get total number of messages
sleep 5

# Poll pending queue and trigger actions if message is present
while :; do

    # Ensure DNS is working before continuing to avoid downstream failures
    rc=1
    while [[ ${rc} -ne 0 ]]; do
        host -t A deb.debian.org && rc=$? || true
        if [[ $rc -ne 0 ]]; then
          log_warn "DNS resolution currently not working. Waiting for DNS resolution to work again before continuing"
          sleep 5
        fi
    done

    completedQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="completed_queue") | .messages')
    wipQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="wip_queue") | .messages')
    failedQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="failed_queue") | .messages')
    retryQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="retry_queue") | .messages')
    pendingQueue=$(rabbitmqadmin list queues name messages --format raw_json | jq -r '.[] | select(.name=="pending_queue") | .messages')
    totalMessages=$(( ${pendingQueue} + ${completedQueue} + ${wipQueue} + ${failedQueue} + ${retryQueue} ))

    if [[ ${failedQueue} -eq 0 ]]; then

        if [[ ${wipQueue} -ne 0 ]]; then

            # In case of system restart, read payload from WIP queue, rather than relying on already set variables
            payload=$(rabbitmqadmin get queue=wip_queue --format=raw_json ackmode=ack_requeue_false | jq -c -r '.[].payload')
            echo "WIP payload: ${payload}"
            export retries=$(echo ${payload} | jq -c -r '.retries')
            export action=$(echo ${payload} | jq -c -r '.action')
            export componentName=$(echo ${payload} | jq -c -r '.name')
            export componentInstallationFolder=$(echo ${payload} | jq -c -r '.install_folder')
            export retriesParameter=$(cat ${autoSetupHome}/${componentInstallationFolder}/${componentName}/metadata.json | jq -r '.retry?')

            # Move item from pending to completed or error queue
            if [[ ! -f ${installationWorkspace}/current_payload.err ]]; then
                echo "Completed payload: ${payload}"
                rabbitmqadmin publish exchange=action_workflow routing_key=completed_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
                log_info "The installation of \"${componentName}\" completed succesfully"
                notify "${componentName} installed successfully [$((${completedQueue} + 1))/${totalMessages}]" "dialog-information"
                if [[ "${componentName}" == "${lastCoreElementToInstall}" ]]; then
                    notify "CONGRATULATIONS\! That concludes the core setup\! Your optional components will now be installed" "dialog-information"
                    echo "${componentName} = ${lastCoreElementToInstall}"
                fi
                retries=0
            else
                if [[ "${retriesParameter}" != "false" ]] && [[ ${retries} -lt 3 ]]; then
                    sleep 10
                    ((retries = ${retries} + 1))
                    payload=$(echo ${payload} | jq --arg retries ${retries} -c -r '.retries=$retries')
                    echo "Retry payload: ${payload}"
                    rabbitmqadmin publish exchange=action_workflow routing_key=retry_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
                    cat ${installationWorkspace}/actionQueues.json | jq -c -r '(.state.processed[] | select(.name=="'${componentName}'").retries) = "'${retries}'"' | tee ${installationWorkspace}/actionQueues.json.tmp
                    mv ${installationWorkspace}/actionQueues.json.tmp ${installationWorkspace}/actionQueues.json
                    log_warn "Previous attempt to install \"${componentName}\" did not complete succesfully. Trying again (${retries} of 3)"
                    notify "${componentName} installation error. Will try three times maximum\! [$((${completedQueue} + 1))/${totalMessages}]" "dialog-warning"
                    rm -f ${installationWorkspace}/current_payload.err
                else
                    payload=$(echo ${payload} | jq -c -r '(.retries)="0"' | jq -c -r '. += {"failed_retries":"'${retries}'"}')
                    echo "Failed payload: ${payload}"
                    rabbitmqadmin publish exchange=action_workflow routing_key=failed_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''
                    retries=0
                    log_error "Previous attempt to install \"${componentName}\" did not complete succesfully. There will be no (further) retries"
                    notify "${componentName} installation failed\! [$((${completedQueue} + 1))/${totalMessages}]" "dialog-error"
                    rm -f ${installationWorkspace}/current_payload.err
                fi
            fi
        fi

        # If there is something in the wip or failed queue, do not schedule an installation
        if [[ ${wipQueue} -eq 0 ]] && [[ ${failedQueue} -eq 0 ]]; then
            if [[ ${retryQueue} -ne 0 ]]; then
                # If no errors or wip, check first if there are any installation items that need to be retried, after a failure was fixed
                payload=$(rabbitmqadmin get queue=retry_queue --format=raw_json ackmode=ack_requeue_false | jq -c -r '.[].payload')
                echo "Payload for retry queue = \"${payload}\""
            elif [[ ${pendingQueue} -ne 0 ]]; then
            # If there were no retry items, check if there is anything in the pending queue that needs to be installed
                payload=$(rabbitmqadmin get queue=pending_queue --format=raw_json ackmode=ack_requeue_false | jq -c -r '.[].payload')
                echo "Payload for pending queue = \"${payload}\""
            else
                payload=""
            fi
            # Start the installation process if an item was found in the pending or retry queue
            if [ -n "${payload}" ]; then
                # Define Variables for autoSetup.sh script
                export action=$(echo ${payload} | jq -r '.action')
                export componentName=$(echo ${payload} | jq -r '.name')
                export componentInstallationFolder=$(echo ${payload} | jq -r '.install_folder')

                # Define component install directory
                export installComponentDirectory=${autoSetupHome}/${componentInstallationFolder}/${componentName}

                # Define location of metadata JSON file for component
                export componentMetadataJson=${installComponentDirectory}/metadata.json

                # Get retry parameter for component
                export retryParameter=$(cat ${componentMetadataJson} | jq -r '.retry?')

                # Add item to wip queue to notify install is in progress
                rabbitmqadmin publish exchange=action_workflow routing_key=wip_queue properties="{\"delivery_mode\": 2}" payload=''${payload}''

                # Launch autoSetup.sh
                if [[ "${componentName}" == "${firstCoreElementToInstall}" ]]; then
                     notify "Initialization started. Please be patient. This could take up to 30 minutes, depending on your system size and speed of internet connection" "dialog-warning"
                    echo "${componentName} = ${firstCoreElementToInstall}"
                fi
                count=$((count + 1))
                export error=""

                # Check if the Docker Hub Download Rate Limit is being reached which may lead to error and notify the user appropriately
                # User Dockerhub account if it exists
                checkDockerHubRateLimit

                # Launch the component installation process
                logFilename=$(setLogFilename)
                . ${autoSetupHome}/autoSetup.sh &> ${logFilename}
                logRc=$?
                log_info "Installation process for \"${componentName}\" returned with \$?=${logRc} and rc=$rc"
            fi
            sleep 5
        fi
        sleep 5
    fi
    sleep 5
done
