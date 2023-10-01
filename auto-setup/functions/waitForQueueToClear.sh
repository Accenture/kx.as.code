waitForQueueToClear() {

  local queueName="${1}"

  # Waiting for payload to arrive on message queue it was sent to
  timeout -s TERM 30 bash -c \
    'while [[ "$(rabbitmqadmin list queues name messages --format raw_json | jq -r ".[] | select(.name==\"'${queueName}'\") | .messages")" -ne 0 ]]; \
    do \
      echo "Waiting for queue \"'${queueName}'\" to clear before continuing to process" && sleep 3; \
  done'

}
