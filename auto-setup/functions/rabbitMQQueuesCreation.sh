createRabbitMQQueues() {
  for actionWorkflowQueue in ${actionWorkflows}; do
    actionWorkflowQueueExists=$(rabbitmqadmin list queues --format=raw_json | jq -r '.[] | select(.name=="'${actionWorkflowQueue}'_queue")')
    if [ -z "${actionWorkflowQueueExists}" ]; then
        rabbitmqadmin declare queue name=${actionWorkflowQueue}_queue durable=true
    fi
  done
}