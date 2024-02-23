# Manual Provisioning

Whilst it is possible and recommended to install applications via the KX.AS.CODE Portal, it is also possible to install applications and tools from the command line using RabbitMQ CLI tools. Below the command for each application for copying and pasting onto the command line.

!!! tip
    See the [installation groups](./Provisioning-Templates.md) page for installing multiple applications from the command line at once.

## Available Applications

All you need to do is find the application you are interested in, copy the install command, then paste it into a command line session within the KX.AS.CODE environment.

|                               Application                                | Category          | Short  Description                         | Install  Command                                                                                                                                                                         |
|:------------------------------------------------------------------------:| ----------------- | ------------------------------------------ |------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|             ![argocd](../assets/images/argocd.png)ArgoCD              | CICD              | Git-Ops                                    | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"argocd","action":"install","retries":"0"}'                         |
|    ![elasticsearch](../assets/images/es.png)Elastic ElasticSearch     | Monitoring        | Data Store and Search Engine               | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"elastic-elasticsearch-oss","action":"install","retries":"0"}' |
|      ![filebeat](../assets/images/filebeat.png)Elastic Filebeat       | Monitoring        | Log Aggregation                            | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"elastic-filebeat-oss","action":"install","retries":"0"}'      |
|         ![kibana](../assets/images/kibana.png)Elastic Kibana          | Monitoring        | Monitoring Visualization                   | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"elastic-kibana-oss","action":"install"}                       |
|               ![gitea](../assets/images/gitea.png)Gitea               | CICD              | Git Repository                             | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"gitea","action":"install","retries":"0"}'                           |
|            ![gitlab](../assets/images/gitlab.png)Gitlab CE            | CICD              | Git Repository and CICD  Pipelines         | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"gitlab","action":"install","retries":"0"}'                          |
|            ![grafana](../assets/images/grafana.png)Grafana            | Monitoring        | Monitoring Visualization                   | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"grafana","action":"install","retries":"0"}'                   |
|    ![grafana](../assets/images/grafana.png)Grafana Image Renderer     | Monitoring        | Image Rendering for Grafana  -> Mattermost | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"grafana-image-renderer","action":"install","retries":"0"}'    |
|          ![graphite](../assets/images/graphite.png)Graphite           | monitoring        | Time-Series Database for  SiteSpeed.io     | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"graphite","action":"install","retries":"0"}'                  |
|             ![harbor](../assets/images/harbor.png)Harbor              | CICD              | Docker Registry                            | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"harbor","action":"install","retries":"0"}'                          |
|        ![consul](../assets/images/consul.png)HashiCorp Consul         | CICD              | Service Discovery                          | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"consul","action":"install","retries":"0"}'                          |
|         ![vault](../assets/images/vault.png)HashiCorp Vauilt          | Security          | Secure Credential Store                    | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"security","name":"vault","action":"install","retries":"0"}'                       |
|            ![jenkins](../assets/images/jenkins.png)Jenkins            | CICD              | Continuous Delivery                        | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"jenkins","action":"install","retries":"0"}'                         |
| ![artifactory](../assets/images/artifactory.png)JFrog Artifactory OSS | CICD              | Artifact Store                             | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"artifactory-oss","action":"install","retries":"0"}'                 |
|         ![books](../assets/images/books.png)KX.AS.CODE "Docs"         | KX.AS.CODE        | KX.AS.CODE Documentation                   | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"kx_as_code","name":"kx.as.code_docs","action":"install","retries":"0"}'           |
|   ![techradar](../assets/images/techradar.png)KX.AS.CODE TechRadar    | KX.AS.CODE        | Technology Radar                           | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"kx_as_code","name":"kx.as.code_techradar","action":"install","retries":"0"}'      |
|       ![mattermost](../assets/images/mattermost.png)Mattermost        | Collaboration     | ChatOps                                    | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"collaboration","name":"mattermost","action":"install","retries":"0"}'             |
|        ![minio](../assets/images/minio.png)MinIO Object Store         | Storage           | S3 Object Storage                          | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"storage","name":"minio-operator","action":"install","retries":"0"}'               |
|         ![neuvector](../assets/images/neuvector.png)NeuVector         | Security          | Container Runtime Security                          | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"security","name":"neuvector","action":"install","retries":"0"}'                   |
|         ![nextcloud](../assets/images/nextcloud.png)Nextcloud         | Storage           | Cloud Storage                              | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"storage","name":"nextcloud","action":"install","retries":"0"}'                    |
|            ![nexus](../assets/images/nexus.png)Nexus 3 OSS            | CICD              | Artifact Store                             | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"cicd","name":"nexus","action":"install","retries":"0"}'                           |
|       ![prometheus](../assets/images/prometheus.png)Prometheus        | Monitoring        | Monitoring Store                           | publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"prometheus","action":"install","retries":"0"}'                              |
|       ![rocketchat](../assets/images/rocketchat.png)RocketChat        | Collaboration     | ChatOps                                    | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"collaboration","name":"rocketchat","action":"install","retries":"0"}'             |
|          ![selenium](../assets/images/selenium.png)Selenium           | Quality Assurance | E2E Browser Test Automation                | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"quality_assurance","name":"selenium","action":"install","retries":"0"}'           |
|         ![sonarqube](../assets/images/sonarqube.png)SonarQube         | Quality Assurance | Code Quality                               | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"quality_assurance","name":"sonarqube","action":"install","retries":"0"}'          |
|    ![sysdig-falco](../assets/images/sysdig-falco.png)Sysdig Falco     | Security          | Container Runtime Security                 | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"security","name":"sysdig-falco","action":"install","retries":"0"}'                |
|            ![grafana-loki](../assets/images/loki.png)loki             | Monitoring        | Datastore and logging                      | rabbitmqadmin publish  exchange=action_workflow routing_key=pending_queue  payload='{"install_folder":"monitoring","name":"loki","action":"install","retries":"0"}'}'                    |

## Managing the Queues

When you copy the lines above into a shell in the KX.AS.CODE workstation, you will see the following.

<img src="../../assets/images/image-20201119214048428.png" alt="image-20201119214048428.png" align="left"/>

In the example above, multiple messages were posted, as the GitOps group below was used in this example.

To get a status on the installation process, just enter `rabbitmqadmin list queues`.

<img src="../../assets/images/image-20201119212520373.png" alt="image-20201119212520373.png" align="left"/>

You can also get a status by visiting the MQ admin site, by double clicking on it's icon on the desktop:

<img src="../../assets/images/image-20201119212844534.png" alt="image-20201119212844534.png" align="left"/>

The username and password is the default guest/guest.

Once opened, navigate to the "queues".

<img src="../../assets/images/image-20201119213106442.png" alt="" align="left"/>

If anything ends up in the `failed_queue`, you must either `purge` it from the queue, or fix whatever it was that prevented it from installing and then move the item to the `retry_queue`.

Moving a message is simple. Just go into the failed_queue detail page by clicking it's name on the queue list and then scrolling down to `move_messages` and entering `retry_queue` in the `Destination queue` field, subseqeuently hitting the `Move messages` button.

<img src="../../assets/images/image-20201119213436428.png" alt="image-20201119213436428.png" align="left"/>
