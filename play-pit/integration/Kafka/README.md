!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

# README

## Description
Apache Kafka is an open source project for a distributed publish-subscribe messaging system rethought as a distributed commit log. Kafka stores messages in topics that are partitioned and replicated across multiple brokers in a cluster. Producers send messages to topics from which consumers read.


## Architecture
Kafka is running as container on k8s cluster. The provided main.sh script has all the required steps for managing the Kafka installation.

## Assumptions
Assuming that the target host has enough resources available. For a minimal setup at least 4G memory and 5G disk space should be available.

## Required Components
- K8s cluster is deployed and accessible.
- Helm is configured.
- Access to Confluent repository is available

## Important Information / Pitfalls
If the deployment took long, check out the pod status by "kubectl get pods --all-namespaces" and be sure that you have enough available resources for k8s cluster. Sometimes, pulling the image is taking long and the pod status is stuck at "ContainerCreating" stage.

## Installation
Change directory to 02_Kubernetes/07_Message_Broker/01_Kafka and use main.sh script for managing Kafka installation:

~~~~
# Install
./main.sh -s helm

# Remove
./main.sh -d helm

# Help
./main.sh --help
~~~~

## Usage
### Zookeeper
1. Deploy a zookeeper client pod with configuration:

~~~~
    apiVersion: v1
    kind: Pod
    metadata:
      name: zookeeper-client
      namespace: default
    spec:
      containers:
      - name: zookeeper-client
        image: confluentinc/cp-zookeeper:5.4.1
        command:
          - sh
          - -c
          - "exec tail -f /dev/null"
~~~~

2. Log into the Pod

~~~~
  kubectl exec -it zookeeper-client -- /bin/bash
~~~~

3. Use zookeeper-shell to connect in the zookeeper-client Pod:

~~~~
  zookeeper-shell my-confluent-oss-cp-zookeeper:2181
~~~~

4. Explore with zookeeper commands, for example:

~~~~
  # Gives the list of active brokers
  ls /brokers/ids

  # Gives the list of topics
  ls /brokers/topics

  # Gives more detailed information of the broker id '0'
  get /brokers/ids/0
~~~~

### Kafka
To connect from a client pod:

1. Deploy a kafka client pod with configuration:

~~~~
    apiVersion: v1
    kind: Pod
    metadata:
      name: kafka-client
      namespace: default
    spec:
      containers:
      - name: kafka-client
        image: confluentinc/cp-enterprise-kafka:5.4.1
        command:
          - sh
          - -c
          - "exec tail -f /dev/null"
~~~~

2. Log into the Pod

~~~~
  kubectl exec -it kafka-client -- /bin/bash
~~~~

3. Explore with kafka commands:

~~~~
  # Create the topic
  kafka-topics --zookeeper my-confluent-oss-cp-zookeeper-headless:2181 --topic my-confluent-oss-topic --create --partitions 1 --replication-factor 1 --if-not-exists

  # Create a message
  MESSAGE="`date -u`"

  # Produce a test message to the topic
  echo "$MESSAGE" | kafka-console-producer --broker-list my-confluent-oss-cp-kafka-headless:9092 --topic my-confluent-oss-topic

  # Consume a test message from the topic
  kafka-console-consumer --bootstrap-server my-confluent-oss-cp-kafka-headless:9092 --topic my-confluent-oss-topic --from-beginning --timeout-ms 2000 --max-messages 1 | grep "$MESSAGE"
~~~~

## Troubleshooting
TBD
