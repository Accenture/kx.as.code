# Adding a Solution

Adding a new solution is straightforward. Here are the steps for doing so.

1. Determine category. Current available categories are as follows:

| Category | Examples |
| --- | --- |
|cicd| Gitlab, TeamCity, Artifactory, Nexus3, Jenkins |
|collaboration| RocketChat, Mattermost, Jira, Confluence, WikiJs |
|dev_tools| BackStage, Atom, Postman|
|monitoring|Prometheus, Tick-Stack, Elastic-Stack, Loki-Stack, Netdata |
|quality_assurance|Selenium-Grid, SonarQube|
|security|Hashicorp Vault, Sysdig Falco|
|storage|Minio-S3|

2. Determine install method (ArgoCD, Helm or purely Script based)

3. Create the needed directory structure for the desired installation method

##### Helm

Below a Helm example for a SonarQube installation


<pre><code>
.
<span style="color: red;">├── auto-setup
│   ├── quality_assurance
│   │   └── sonarqube
│   │       ├── metadata.json</span>
<span style="color: orange;">│   │       ├── post_install_scripts</span>
│   │       │   ├── configureSonarQube.sh
│   │       │   └── createGitlabOauthApplication.sh
<span style="color: orange;">│   │       ├── pre_install_scripts</span>
│   │       │   ├── createCaSecret.sh
│   │       │   ├── createOauthIntegration.sh
│   │       │   └── createPostgresPassword.sh
<span style="color: orange;">│   │       ├── screenshots</span>
│   │       │   ├── sonarqube_screenshot1.png
│   │       │   ├── sonarqube_screenshot2.png
│   │       │   └── sonarqube_screenshot3.png
<span style="color: red;">│   │       ├── sonarqube.png</span>
<span style="color: orange;">│   │       └── values_template.yaml</span>
</code>
</pre>

The configuration file, `metadata.json`, is absolutely mandatory for each component directory. This tells the KX.AS.CODE installation framework exactly what and how to install the application in question.

See the following guide that describes in detail 

The scripts in the various directories are also listed in the metadata.json, in order to ensure they are executed in the correct order. It also means a script can be temporarily removed from the installation process wihout deleting it.

The directories highlighted in red are mandatory. The directories in orange are optional.
Scripts in the `pre_install_scripts` directory will be executed before the main scripts, and subsequently the scripts in the `post_install_scripts` directory.

##### ArgoCD

##### Scripts

