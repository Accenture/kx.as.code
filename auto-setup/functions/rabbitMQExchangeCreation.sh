createRabbitMQExchange() {
  exchangeExists=$(rabbitmqadmin list exchanges --format=raw_json | jq -r '.[] | select(.name=="action_workflow")')
  if [ -z "${exchangeExists}" ]; then
    rabbitmqadmin declare exchange name=action_workflow type=direct
  fi
}
