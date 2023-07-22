waitForMessageOnActionQueue() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  local queueName="${1}"
  local componentName="${2}"

  # Waiting for payload to arrive on message queue it was sent to
  timeout -s TERM 30 bash -c \
  'while [[ "$(curl -s -u guest:guest -H "content-type:application/json" -X POST http://localhost:15672/api/queues/%2f/'${queueName}'/get -d"{\"count\":10000,\"ackmode\":\"ack_requeue_true\",\"encoding\":\"auto\",\"truncate\":50000}" | jq -r "last | .payload" | jq -r ".name")" != '${componentName}' ]]; \
    do \
      echo "Waiting for payload for \"'${componentName}'\" to arrive in \"'${queueName}'\" message queue" && sleep 3; \
  done'

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
