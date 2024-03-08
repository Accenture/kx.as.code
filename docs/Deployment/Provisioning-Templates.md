# Installation Groups

The advantage of installation groups is that they are scripted to integrate with each other. This may not be the case if you install individual applications that have not been scripted and tested to work together.

There are currently two ways to install applications groups. Either via the Jenkins launcher before KX.AS.CODE has been started, and via the command line, after KX.AS.CODE has been started.

## Via the Jenkins based Launcher

See the [guide](../Quick-Start-Guide.md) for starting the [launcher](../Quick-Start-Guide.md) if you have not already done so.

![](../assets/images/kx-as-code_configurator_template-selector.png){: .zoom}

You can select multiple groups, but please heed the warning below.

!!! warning
    If you have a low number of resources (less than 16GB ram), you need to be careful that you don't overload your environment.

!!! info
    In future it will also be possible to install application groups via the KX Portal, but this is still in development and the feature is not ready yet.

!!! tip
    You can also add additional groups to KX.AS.CODE by creating another template in the [templates](https://github.com/Accenture/kx.as.code/tree/main/templates){:target="\_blank"} folder.

    If you refresh your browser, you should see the template added to the menu in the Jenkins based launcher.

    Use the other templates to get an example of what is needed.

## From the command line

!!! note
    You need to be either SSH'd into the KX.AS.CODE environment, or open a terminal session inside KX.AS.CODE desktop itself, for these commands to work.

You could create your own installation groups, but below some of the ones that have already been developed.

### GitOps Group

Included in this group are:

- MinIo-Operator
- Gitlab CE
- Mattermost
- Harbor
- ArgoCD
- jFrog Artifactory

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"storage","name":"minio-operator","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"gitlab","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"collaboration","name":"mattermost","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"harbor","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"argocd","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"artifactory","action":"install","retries":"0"}'
```

### CICD Group

- Jenkins
- Gitea
- Nexus3
- RocketChat

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"jenkins","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"gitea","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"collaboration","name":"rocketchat","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"cicd","name":"nexus3","action":"install","retries":"0"}'
```

### Quality Assurance Group

Included in this group are:

- SonarQube
- Selenium

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"quality_assurance","name":"sonarqube","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"quality_assurance","name":"selenium4","action":"install","retries":"0"}'
```

### Elastic Stack

Included in this group are:

- Elastic ElasticSearch
- Elastic Kibana
- Elastic Filebeat
- Elastic Metricbeat
- Elastic Heartbeat

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"elastic-elasticsearch","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"elastic-kibana","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"elastic-filebeat","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"elastic-metricbeat","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"elastic-heartbeat","action":"install","retries":"0"}'
```

### Monitoring and Log Aggregation Group

Included in this group are:

- Prometheus
- Grafana
- Loki
- Graphite

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"prometheus","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"grafana","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"loki","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"graphite","action":"install","retries":"0"}'
```

### Security Group

Included in this group are:

- HashiCorp Vault
- Sysdig Falco

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"security","name":"vault","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"security","name":"sysdig-falco","action":"install","retries":"0"}'
```

### Tick Stack

Included in this group are:

- Influxdb2
- Telegraf DS
- Telegraf

```bash
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"influxdata-influxdb2","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"influxdata-telegraf-ds","action":"install","retries":"0"}'
rabbitmqadmin publish exchange=action_workflow routing_key=pending_queue payload='{"install_folder":"monitoring","name":"influxdata-telegraf","action":"install","retries":"0"}'
```
