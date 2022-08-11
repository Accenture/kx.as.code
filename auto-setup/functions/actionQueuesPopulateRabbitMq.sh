populateActionQueuesRabbitMq() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

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
  
    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}
