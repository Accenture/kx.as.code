# Installation Flow

------

This section describes the execution flow for items added for installation from the KX.AS.CODE frontend.

Once the instruction to install a tool is received from the frontend (by adding it to the "pending" queue in RabbitMQ), the installation flow for all tool installations is as follows.

[![KX.AS.CODE Architecture-Installation Flow](images/KX.AS.CODE Architecture-Installation Flow.png)](images/KX.AS.CODE Architecture-Installation Flow.png)




The metadata.json that accompanies each solution determines which main installation method is used:

- Script
- Helm3
- ArgoCD



Below a detail description for defining the contents of metadata,json.



#### General Options

Before going into the detail of each installation type, here the general configuration items that are relevant for all types. The following options are an example from the metadata.json for the Gitlab CE installation.

```json
{
	"name": "gitlab-ce",
    "namespace": "gitlab-ce",
    "installation_type": "helm",
    "installation_group_folder": "cicd",
    "environment_variables": {
        "gitabRunnerVersion": "v13.4.1",
        "s3BucketsToCreate": "gitlab-artifacts-storage;gitlab-backup-storage;gitlab-lfs-storage;gitlab-packages-storage;gitlab-registry-storage;gitlab-uploads-storage;runner-cache"
    },
    "categories": [
        "git-repository",
        "docker-registry",
        "cicd"
    ],
	"Description": "Gitlab CE Git Repository and CICD",
	"shortcut_text": "Gitlab CE",
	"shortcut_icon": "gitlab.png",
	"api_docs_url": "https://gitlab.{{baseDomain}}/help/api/api_resources.md",
	"vendor_docs_url": "https://docs.gitlab.com/ce/"
}
```


| Parameter                 | Description                                                  | Mandatory/Optional |
| ------------------------- | ------------------------------------------------------------ | ------------------ |
| name                      | The name of the application to be installed.                 | Mandatory          |
| namespace                 | The Kubernetes namespace- Must be define if installing via ArgoCD or Helm, if if the script based installation process requires it. | Optional           |
| installation_type         | Can be either `script`, `helm` or `argocd`. Is Helm or ArgoCD, then the Helm or ArgoCD parameters must also be defined | Mandatory          |
| installation_group_folder | The group folder under the "auto-setup" folder which contains the folder for the solution in question | Mandatory          |
| environment_variables     | If any variables are needed during any parts of the installation, define them here. If you add them in configuration files as Mustache variables, ie `{{variable}}`, then these will automatically be replaced. Alternatively, just use`${variable}`  if using them in a script | Optional           |
| categories[]              | This is for filtering on the front end                       | Optional           |
| Description               | This is for showing a description of the tool on the frontend | Optional           |
| shortcut_text             | The name of the tool for the tool's shortcut on the desktop  | Optional           |
| shortcut_icon             | Filename for the picture to use for the desktop shortcut icon. The file must be placed in the same folder as the metadata.json. | Optional           |
| api_docs_url              | URL to the tool's API documentation provided by the vendor. Setting this will result in a desktop icon in the `API Docs` folder | Optional           |
| vendor_docs_url           | URL to the tool's documentation provided by the vendor. Setting this will result in a desktop icon in the `Vendor Docs` folder | Optional           |
| swagger_docs_url          | URL to the tool's live `Swagger API UI`. Setting this will result in a desktop icon in the "API Docs" folder | Optional           |
| postman_docs_url          | URL to the tool's `Postman API`documentation provided by the vendor. Setting this will result in a desktop icon in the "API Docs" folder | Optional           |



### Use of Variables

**Replacements**

The installation process fully supports variable replacements with the `mustache` syntax. See the following [link](https://mustache.github.io/mustache.5.html) for more details.

Mustache placeholders can be placed in Helm parameters of the `values_template.yaml` files.

For --set the [mo](https://github.com/tests-always-included/mo) command is used to conduct the replacement. However, due to the limitation with "mo" (exclusion syntax not working), for the YAML value templates the mustache replacement utility is [enhandlebars](https://www.npmjs.com/package/envhandlebars), installed via NPM.



**Global**

These are defined in autoSetup.json and are available to all scripts and templates.

Here a list of global variables that can be used in any script with `${variable}` or any ArgoCD/Helm template/--set parameters with `{{variable}}`.

| Parameter                 | Example Value                                        | Description                                                  |
| ------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| componentName             | gitlab-ce                                            | Name of the component to be installed                        |
| baseDomain                | kx-as-code.local                                     | The base domain. If a team name is defined, that will be added to the base domain. This is recommended if there are multiple KX.AS.CODE installations in one location |
| environmentPrefix         | team1                                                | The name of the team for the KX.AS.CODE installation. This will be prepended to the base domain |
| vmUser                    | kx.hero                                              | The user for the VM login                                    |
| vmPassword                | L3arnandshare                                        | The password for the VM login                                |
| installationWorkspace     | /home/kx.hero/Kubernetes                             | The working area for all installations, including installation logs |
| autoSetupHome             | /home/kx.hero/Documents/kx.as.code_source/auto-setup | The root folder for all component installation sub folders   |
| mainIpAddress             | 192.168.40.150                                       | The IP address of the KX.AS.CODE main machine                |
| defaultGitPath            | cicd/gitlab-ce                                       | The default path for the git server in this KX.AS.CODE installation |
| gitDomain                 | gitlab.team1.kx-as-code.local                        | The domain of the default Git installation                   |
| gitUrl                    | https://gitlab.team1.kx-as-code.local                | The URL of the default Git installation                      |
| defaultOauthPath          | cicd/gitlab-ce                                       | The default path for the OAUTH server in this KX.AS.CODE installation |
| oauthDomain               | gitlab.team1.kx-as-code.local                        | The domain of the default OAUTH installation                 |
| oauthUrl                  | https://gitlab.team1.kx-as-code.local                | The URL of the default Git installation                      |
| defaultChatopsPath        | collaboration/mattermost                             | The default path for the ChatOps server in this KX.AS.CODE installation |
| chatopsDomain             | mattermost.team1.kx-as-code.local                    | The domain of the default ChatOp sinstallation               |
| chatopsUrl                | https://mattermost.team1.kx-as-code.local            | The URL of the default ChatOp installation                   |
| defaultDockerRegistryPath | cicd/harbor                                          | The default path for the Docker Registry server in this KX.AS.CODE installation |
| dockerRegistryDomain      | harbor.team1.kx-as-code.local                        | The domain of the default Docker Registry installation       |
| dockerRegistryUrl         | https://harbor.team1.kx-as-code.local                | The URL of the default Docker Registry installation          |
| defaultS3ObjectStorePath  | cicd/minio-s3                                        | The default path for the S3 object storage server in this KX.AS.CODE installation |
| s3ObjectStoreDomain       | minio-s3.team1.kx-as-code.local                      | The domain of the default S3 object storage installation     |
| s3ObjectStoreUrl          | https://minio-s3.team1.kx-as-code.local              | The URL of the default S3 object storageinstallation         |



**Local**

These are defined in each solution's metadata.json in the `environment_variables[]` array.

For example, here from Grafana.

```json
{
    "environment_variables": {
        "grafanaVersion": "7.1.5"
    }
}
```
In this example, this variable is later used in the `helm_params.set_key_values[]` array.

```json
{
	"helm_params": {
		"set_key_values": [
    	   	 "image.repository={{dockerRegistryDomain}}/devops/grafana",
    	   	 "image.tag={{grafanaVersion}}"
     	]
	}
}
```


#### Pre-Scripts

These scripts run before the main installation process. The usually define pre-requisites, such as creating passwords, users, S3 buckets or any other dependencies that are needed by the main installation process.

```json
{
    "pre_install_scripts": [
        "createGitProject.sh",
        "populateGitProject.sh"
    ],
}
```



#### Post Scripts

These scripts run after the main installation has completed. Example could be using the tool's API after the base installation for additional configuration steps.

```json
{
   "post_install_scripts": [
        "configureCoreDnsWithKxAsCodeDnsServer.sh",
        "enableWorkloadsOnMaster.sh"
    ]
}
```



#### Health Checks

Health checks are executed after the pre- and main installation routines have run, but before the post- steps are executed. This is so that the solution is up and working before any post-steps run, which may be reliant on the solution's API.

Below is an example from the `metadata.json` for Gitlab CE.

Apart from defining the expected HTTP return code, it is also possible to define either the expected string or json response on a successful health-check.

The json_path uses the `JSONPath ` notation. See the following [link](https://restfulapi.net/json-jsonpath/#:~:text=JSONPath%20Syntax&text=The%20dollar%20sign%20is%20followed,important%20JSONPath%20syntax%20rules%20are%3A&text=%5B%20%5D%20is%20the%20subscript%20operator%2C,(by%20name%20or%20index).) for more details. The tool use at the backend is `jq`, so if your query works with that, it will work here too.

```json
{
    "urls": [
        {
            "url": "https://gitlab.{{baseDomain}}",
            "healthchecks": {
                "liveliness": {
                    "http_path": "/-/liveliness",
                    "http_auth_required": false,
                    "expected_http_response_code": "200",
                    "expected_http_response_string": "",
                    "expected_json_response": {
                        "json_path": ".status",
                        "json_value": "ok"
                    },
                    "health_shell_check_command": "",
                    "expected_shell_check_command_response": ""
                },
                "readiness": {
                    "http_path": "/-/readiness",
                    "http_auth_required": false,
                    "expected_http_response_code": "200",
                    "expected_http_response_string": "",
                    "expected_json_response": {
                        "json_path": ".status",
                        "json_value": "ok"
                    }
                }
            }
        }
    ]
}
```


### Script Install Method

This is the simplest form of installation. In this case a bash script needs to be defined and dropped into the solution's installation directory along with the metadata.json.

Here any example of a complete metadata.json file for the script installation method. As you can see, it's very simple.

```json
{
    "name": "kubernetes-base-services",
    "Description": "Kubernetes Base Services",
    "namespace": "kube-system",
    "installation_type": "script",
    "installation_group_folder": "kubernetes_core",
    "install_scripts": [
        "installKubernetesBaseServices.sh"
    ],
    "pre_install_scripts": [],
    "post_install_scripts": [
        "configureCoreDnsWithKxAsCodeDnsServer.sh",
        "enableWorkloadsOnMaster.sh"
    ]
}
```





### Helm3 Install Method

If you are familiar with the Helm installation process, you  will recognized the parameters below.  Again, here a full example from the Gitlab CE installation.

For a Helm installation, the general parameters described have too be set, plus the helm specific parameters under `helm_params`.

```json
{
    "name": "harbor",
    "namespace": "harbor",
    "installation_type": "helm",
    "installation_group_folder": "cicd",
    "helm_params": {
        "repository_url": "https://helm.goharbor.io",
        "repository_name": "harbor/harbor",
        "set_key_values": [
            "persistence.enabled=true",
            "persistence.persistentVolumeClaim.registry.storageClass=local-storage",
            "persistence.persistentVolumeClaim.registry.size=9Gi",
            "persistence.persistentVolumeClaim.chartmuseum.size=5Gi",
            "persistence.persistentVolumeClaim.chartmuseum.storageClass=gluster-heketi",
            "persistence.persistentVolumeClaim.database.size=5Gi",
            "persistence.persistentVolumeClaim.database.storageClass=local-storage",
            "persistence.persistentVolumeClaim.redis.storageClass=local-storage",
            "persistence.persistentVolumeClaim.jobservice.storageClass=gluster-heketi",
            "persistence.persistentVolumeClaim.trivy.storageClass=gluster-heketi",
            "expose.type=ingress",
            "externalURL=https://{{componentName}}.{{baseDomain}}",
            "expose.ingress.hosts.core={{componentName}}.{{baseDomain}}",
            "expose.ingress.hosts.notary=notary.{{baseDomain}}",
            "expose.tls.enabled=true",
            "expose.tls.caBundleSecretName=kx.as.code-wildcard-cert",
            "expose.tls.caSecretName=kx.as.code-wildcard-cert",
            "expose.tls.secretName=kx.as.code-wildcard-cert",
            "expose.tls.notarySecretName=kx.as.code-wildcard-cert",
            "harborAdminPassword=\"{{vmPassword}}\"",
            "expose.ingress.annotations.\"nginx\\.ingress\\.kubernetes\\.io/proxy-body-size\"=\"10000m\"",
            "logLevel=debug"
        ]
    },
    "categories": [
        "docker-registry",
        "helm-repository"
    ],
    "urls": [
        {
            "url": "https://{{componentName}}.{{baseDomain}}",
            "healthchecks": {
                "liveliness": {
                    "http_path": "/",
                    "http_auth_required": false,
                    "expected_http_response_code": "200",
                    "expected_http_response_string": "",
                    "expected_json_response": {
                        "json_path": "",
                        "json_value": ""
                    },
                    "health_shell_check_command": "",
                    "expected_shell_check_command_response": ""
                },
                "readiness": {
                    "http_path": "/",
                    "http_auth_required": false,
                    "expected_http_response_code": "200",
                    "expected_http_response_string": "",
                    "expected_json_response": {
                        "json_path": "",
                        "json_value": ""
                    },
                    "health_shell_check_command": "",
                    "expected_shell_check_command_response": ""
                }
            }
        }
    ],
    "Description": "Harbor Description",
    "shortcut_text": "Harbor",
    "shortcut_icon": "harbor.png",
    "swagger_docs_url": "https://{{componentName}}.{{baseDomain}}/devcenter-api-2.0",
    "api_docs_url": "https://goharbor.io/docs/2.1.0/build-customize-contribute/configure-swagger/",
    "vendor_docs_url": "https://goharbor.io/docs",
    "pre_install_scripts": [
        "createSecret.sh"
    ],
    "post_install_scripts": [
        "createIngress.sh",
        "createProjects.sh",
        "createRobotAccounts.sh"
    ]
}
```



| Parameter        | Description                                                  | Mandatory/Optional |
| ---------------- | ------------------------------------------------------------ | ------------------ |
| repository_url   | The URL of the repository where the Helm chart is located    | Mandatory          |
| repository_name  | The name of the chart repository to install                  | Mandatory          |
| set_key_values[] | This is an array where additional parameters can be defined. These will automatically be added as `--set` parameters when defining the Helm install command. Apart from using this array, it is also possible to define a `values_template.yaml`. More details below. Variable defined in the `mustache` syntax will automatically be replaced with either globally or locally defined values. Local value are defined in `metadata.json`, whilst global values are defined in `autoSetup.json`. | Optional           |

As well as defining additional parameters in the `set_key_values[]` array, it is also possible to define them in a values.yaml file.

The file must be define with the name `values_template.yaml` and place in the same folder as metadata.json.

Variable defined in the `mustache` syntax will automatically be replaced with either globally or locally defined values. Local value are defined in `metadata.json`, whilst global values are defined in `autoSetup.json`.

For more details on the workings of the Helm value.yaml file, read the following [documentation](https://helm.sh/docs/chart_template_guide/values_files/).



### ArgoCD Install Method

As above, here an example metadata.json file for an installation via ArgoCD.

```json
{
    "name": "grafana-image-renderer",
    "namespace": "monitoring",
    "installation_type": "argocd",
    "installation_group_folder": "monitoring",
    "argocd_params": {
        "repository": "{{gitUrl}}/devops/grafana_image_renderer.git",
        "path": ".",
        "dest_server": "https://kubernetes.default.svc",
        "dest_namespace": "devops",
        "sync_policy": "automated",
        "auto_prune": true,
        "self_heal": true
    },
    "categories": [
        "visualization",
        "monitoring"
    ],
    "urls": [
        {
            "url": "",
            "healthchecks": {
                "liveliness": {
                    "http_path": "/",
                    "http_auth_required": false,
                    "expected_http_response_code": "200",
                    "expected_http_response_string": "",
                    "expected_json_response": {
                        "json_path": "",
                        "json_value": ""
                    },
                    "health_shell_check_command": "",
                    "expected_shell_check_command_response": ""
                },
                "readiness": {
                    "http_path": "/",
                    "http_auth_required": false,
                    "expected_http_response_code": "200",
                    "expected_http_response_string": "",
                    "expected_json_response": {
                        "json_path": "",
                        "json_value": ""
                    },
                    "health_shell_check_command": "",
                    "expected_shell_check_command_response": ""
                }
            }
        }
    ],
    "Description": "Grafana Image Renderer Description",
    "shortcut_text": "",
    "shortcut_icon": "",
    "pre_install_scripts": [
        "createGitProject.sh",
        "populateGitProject.sh"
    ],
    "post_install_scripts": []
}
```

Below a description for each parameter.

| Parameter      | Description                                                  | Mandatory/Optional |
| -------------- | ------------------------------------------------------------ | ------------------ |
| repository     | The GIT repository URL where the Kubernetes YAML file are stored | Mandatory          |
| path           | The path the the YAML file within the Git repository. Just enter "." if the files are in the root of the repository | Mandatory          |
| dest_server    | The destination Kubernetes server. If in doubt, use the Kubernetes default, `https://kubernetes.default.svc` | Mandatory          |
| dest_namespace | The Kubernetes namespace into which the solution should be deployed | Mandatory          |
| sync_policy    | If set to automated, will always sync the latest state in Git and ensure the state in Kubernetes matches that | Mandatory          |
| auto_prune     | If set to true, automatically deletes resources in Kubernetes that are no longer defined in gIt. | Mandatory          |
| self_heal      | If selfHeal flag is set to true then sync will be attempted again after self heal timeout (5 seconds by default) |                    |

For full instructions on the workings of ArgoCD, see their detailed [documentation](https://argoproj.github.io/argo-cd/core_concepts/).
