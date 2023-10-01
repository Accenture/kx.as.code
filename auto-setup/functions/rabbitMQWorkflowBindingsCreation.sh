createRabbitMQWorkflowBindings() {

  for actionWorkflowBinding in ${actionWorkflows}; do
    actionWorkflowBindingExists=$(rabbitmqadmin list bindings --format=raw_json | jq -r '.[] | select(.source=="action_workflow" and .destination=="'${actionWorkflowBinding}'_queue")')
    if [ -z "${actionWorkflowBindingExists}" ]; then
      rabbitmqadmin declare binding source="action_workflow" destination_type="queue" destination="${actionWorkflowBinding}_queue" routing_key="${actionWorkflowBinding}_queue"
    fi
  done

  
}
