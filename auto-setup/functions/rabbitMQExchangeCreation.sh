createRabbitMQExchange() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  exchangeExists=$(rabbitmqadmin list exchanges --format=raw_json | jq -r '.[] | select(.name=="action_workflow")')
  if [ -z "${exchangeExists}" ]; then
    rabbitmqadmin declare exchange name=action_workflow type=direct
  fi

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
