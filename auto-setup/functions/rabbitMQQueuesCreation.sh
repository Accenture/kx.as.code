createRabbitMQQueues() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  for actionWorkflowQueue in ${actionWorkflows}; do
    actionWorkflowQueueExists=$(rabbitmqadmin list queues --format=raw_json | jq -r '.[] | select(.name=="'${actionWorkflowQueue}'_queue")')
    if [ -z "${actionWorkflowQueueExists}" ]; then
        rabbitmqadmin declare queue name=${actionWorkflowQueue}_queue durable=true
    fi
  done

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
