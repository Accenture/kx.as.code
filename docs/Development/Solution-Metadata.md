# Solution Metadata

Where profile-config.json, as described [here](../../Deployment/Configuration-Options/), describes the global configuration items, each component that needs to be installed, additionally has its own configuration json, that describes, what, how, and in what order things need to be executed.

The content of metadata.json will depend on the installation method. Currently, the three methods are `Scripts`, `ArgoCD` or `Helm`.

There is a backlog item to support Operators in future, but for now these can be installed via the Script method, so it's currently not the highest priority.

!!! info
    For an example of an Operator installed via the script based method, see the [MinIO Operator installation scripts](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/storage/minio-operator){:target="\_blank"}.
    
    This was based on Helm in the past, but was recently migrated to the Operator. It is described in detail below.

This page is primarily for describing `metadata.json` options. For a more detailed development guide, see the [development walk-through](../../Development/Adding-a-Solution/).

The first table describes the common configuration items for all installation routines. The subsequent tables show the additional configuration items needed specific to the installation method. 

### Common - General Settings

These settings are the configuration items that are common to all installation methods. 

| 	Path Name	                             | Description	                                                                                                                                                                                                                                                 | Example                                                       |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| 	name	                                  | The name of the solution                                                                                                                                                                                                                                     | 	`minio-operator`	                                            |
| 	namespace	                             | The namespace to use in Kubernetes. Will be created if it does not exist                                                                                                                                                                                     | 	`minio-operator`	                                            |
| 	installation_type	                     | `helm`, `argocd`, `scripts`                                                                                                                                                                                                                                  | 	`script`	                                                    |
| 	installation_group_folder	             | The folder under auto-setup where the component is held. eg. cicd, security, mnonitoring, etc                                                                                                                                                                | 	`storage`	                                                   |
| 	environment_variables.operatorVersion	 | Any variables needed during the installation process. These will also be available during the installation process for mustache and environmernt variable substitutions. In this example, the `operatorVersion` is added for use in the installation process | 	`4.4.28`	                                                    |
| 	categories[0]	                         | The categories to show in the KX-Portal GUI for the solution in question. Can be multiple                                                                                                                                                                    | 	`s3-storage`	                                                |
| 	Description	                           | Description of the solution. Will appear in the KX-Portal GUI                                                                                                                                                                                                | 	`MinIO Object Storage`	                                      |
| 	shortcut_text	                         | Text for the desktop icon                                                                                                                                                                                                                                    | 	`MinIO Console`	                                             |
| 	shortcut_icon	                         | Image for the desktop icon and KX-Portal GUI. The image should be placed in the components folder root                                                                                                                                                       | 	`minio.png`	                                                 |
| 	api_docs_type	                         | Options are `web`, `postman` or `swagger`. Web is just static documention, whereas `postman` and `swagger` provide additional facilities to try out the API. This option drops an additional icon to the API Docs folder                                     | 	`web`	                                                       |
| 	api_docs_url	                          | The url in accordance with the `api_docs_type` value                                                                                                                                                                                                         | 	`https://docs.min.io/docs/minio-client-complete-guide.html`	 |
| 	vendor_docs_url	                       | The URL to the vendor's documentation. Will result in an additional link to the `vendor_docs` folder on the desktop                                                                                                                                          | 	`https://docs.min.io`	                                       |
| postman_docs_url                        | The Postman API docs URL.                                                                                                                                                                                                                                    | `https://documenter.getpostman.com/view/4508214/RW8FERUn`     |
| 	swagger_docs_url	                      | The live Swagger URL. Notice the use of `{{componentName}}.{{baseDomain}}`. These will automatically be replaced with the correct values during the installatio proccess.                                                                                    | 	`https://{{componentName}}.{{baseDomain}}/swagger-ui`	       |



### Common - Health Checks

Health checks, especially the readiness checks, are an important part of the installation process, as they determine after the main installation process has completed, if the post steps can run.

Often post installation steps require the solution's API to be available. The health checks ensure post steps do not run until this is so.

The liveliness checks are no yet in use as all tools are monitored for health by Kubernetes, but hey may be used in future inside the KX-Portal. 

| 	Path Name	                                                                 | Description	                                                                                                                                                                                                                                                                            | Example                                              |
|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| 	urls[0].url	                                                               | The URLs to use for the desktop shortcut, and for health checking the application installation. There can be multiple, although 99.9% of the time there will be just one, which is the reason why for the desktops and health-checking, only the first entry ([0] in the array) is used | 	`https://console-{{componentName}}.{{baseDomain}}`	 |
| 	urls[0].healthchecks.liveliness<br/>.http_path	                            | The path to the liveliness health check (such as /api/health). Will be appended to the url.                                                                                                                                                                                             | 	`/`	                                                |
| 	urls[0].healthchecks.liveliness<br/>.http_auth_required	                   | If authentication is required or not                                                                                                                                                                                                                                                    | 	`false`	                                            |
| 	urls[0].healthchecks.liveliness<br/>.expected_http_response_code	          | The HTTP response code to expect. Anything that deviates from that will mean the health check is considered to have failed                                                                                                                                                              | 	`200`	                                              |
| 	urls[0].healthchecks.liveliness<br/>.expected_http_response_string	        | If the health-check returns a sting response, this can be used to check whether the respoinse was as expected. A strring response might be something as simple as "ok"                                                                                                                  | 		                                                   |
| 	urls[0].healthchecks.liveliness<br/>.expected_json_response.json_path	     | If the health-check returns a JSON response, this property defines the JSON path to check for the health status. For example `.app.status.healthy=true`. The path should matrch the path used with the bash `jq` utility                                                                | 		                                                   |
| 	urls[0].healthchecks.liveliness<br/>.expected_json_response.json_value	    | The expected value of the json path for a health state                                                                                                                                                                                                                                  | 		                                                   |
| 	urls[0].healthchecks.liveliness<br/>.health_shell_check_command	           | Not used so far, but an option in case the http based health checks are not enough                                                                                                                                                                                                      | 		                                                   |
| 	urls[0].healthchecks.readiness<br/>.expected_shell_check_command_response	 | The shell check should return RC=0 to be considered a success                                                                                                                                                                                                                           | 		                                                   |
| 	urls[0].healthchecks.readiness<br/>.http_path	                             | The path to the readiness health check (such as /api/health). Will be appended to the url.                                                                                                                                                                                              | 	`/`	                                                |
| 	urls[0].healthchecks.readiness<br/>.http_auth_required	                    | If authentication is required or not                                                                                                                                                                                                                                                    | 	`false`	                                            |
| 	urls[0].healthchecks.readiness<br/>.expected_http_response_code	           | The HTTP response code to expect. Anything that deviates from that will mean the health check is considered to have failed                                                                                                                                                              | 	`200`	                                              |
| 	urls[0].healthchecks.readiness<br/>.expected_http_response_string	         | If the health-check returns a sting response, this can be used to check whether the respoinse was as expected. A strring response might be something as simple as "ok"                                                                                                                  | 		                                                   |
| 	urls[0].healthchecks.readiness<br/>.expected_json_response.json_path	      | If the health-check returns a JSON response, this property defines the JSON path to check for the health status. For example `.app.status.healthy=true`. The path should matrch the path used with the bash `jq` utility                                                                | 		                                                   |
| 	urls[0].healthchecks.readiness<br/>.expected_json_response.json_value	     | The expected value of the json path for a health state                                                                                                                                                                                                                                  | 		                                                   |
| 	urls[0].healthchecks.readiness<br/>.health_shell_check_command	            | Not used so far, but an option in case the http based health checks are not enough                                                                                                                                                                                                      | 		                                                   |
| 	urls[0].healthchecks.readiness<br/>.expected_shell_check_command_response	 | The shell check should return RC=0 to be considered a success                                                                                                                                                                                                                           | 		                                                   |


### Scripts

The example is based on the installation process defined for the MinIO Operator. See here the [full solution](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/storage/minio-operator){:target="\_blank"}.

The scripts based installation process is executed via the following core framework [script](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/functions/autoSetupScriptInstall.sh){:target="\_blank"}.

!!! tip
    This is probably the simplest of the three installation methods, as you can define your scripts in any way you like. Don't forget to make use of the central functions, to not only make your life easier, but also to avoid repeating code unnecessarily.

!!! example
    ```json
    {
        "name": "minio-operator",
        "namespace": "minio-operator",
        "installation_type": "script",
        "installation_group_folder": "storage",
        "environment_variables": {
            "operatorVersion": "4.4.28"
        },
        "categories": [
            "s3-storage"
        ],
        "urls": [
            {
                "url": "https://console-{{componentName}}.{{baseDomain}}",
                "healthchecks": {
                    "liveliness": {
                        "http_path": "/",
                        "http_auth_required": false,
                        "expected_http_response_code": "200",
                        "expected_http_response_string": "",
                        "expected_json_response": {
                            "json_path":"",
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
        "Description": "MinIO Object Storage",
        "shortcut_text": "MinIO Console",
        "shortcut_icon": "minio.png",
        "api_docs_type": "web",
        "api_docs_url": "https://docs.min.io/docs/minio-client-complete-guide.html",
        "vendor_docs_url": "https://docs.min.io",
        "pre_install_scripts": [
            "createSecrets.sh",
            "installMinIoCli.sh"
        ],
        "install_scripts": [
            "installMinioOperator.sh"
        ],
        "post_install_scripts": [
            "intializeMinioOperator.sh"
        ]
    }
    ```

| 	Path Name	               | Description	                                                                                                                                                                                                                                                                                                      | Example                       |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| 	installation_type	       | `scripts`                                                                                                                                                                                                                                                                                                         | 	`script`	                    |
| 	pre_install_scripts[0]	  | Script to execute before the main installation process starts. This is less important for the script based installation method, but more for Helm and ArgoCD. That said, it's still good to use the option here, to make the installation process more readable, rather than having everything in one long script | 	`createSecrets.sh`	          |
| 	pre_install_scripts[1]	  | Same as above. In the case of MinIO, two prescripts are executed                                                                                                                                                                                                                                                  | 	`installMinIoCli.sh`	        |
| 	install_scripts[0]	      | The main installation script to execute                                                                                                                                                                                                                                                                           | 	`installMinioOperator.sh`	   |
| 	post_install_scripts[0]	 | A script containing post installation steps, such as those that required the API to first become available                                                                                                                                                                                                        | 	`intializeMinioOperator.sh`	 |


### Helm

As everything else is the same, the JSON example will be complete, but only the configuration items not already described above will be described in more detail in the table below.

The example is based on the Helm based installation process defined for ArgoCD. See here the [full solution](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/cicd/argocd){:target="\_blank"}.

The Helm installation process is executed via the following [script](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/functions/autoSetupHelmInstall.sh){:target="\_blank"}.

For general information on Helm, visit their [docs site](https://helm.sh/docs/){:target="\_blank"}.

!!! example
    ```json
    {
        "name": "argocd",
        "namespace": "argocd",
        "installation_type": "helm",
        "installation_group_folder": "cicd",
        "environment_variables": {
            "imageTag": "v2.4.8"
        },
        "helm_params": {
            "repository_url": "https://argoproj.github.io/argo-helm",
            "repository_name": "argo/argo-cd",
            "helm_version": "4.10.5",
            "set_key_values": [
                "global.image.tag={{imageTag}}",
                "installCRDs=false",
                "configs.secret.argocdServerAdminPassword='{{argoCdAdminPassword}}'",
                "controller.clusterAdminAccess.enabled=true",
                "server.clusterAdminAccess.enabled=true",
                "server.extraArgs[0]=--insecure"
            ]
        },
        "categories": [
            "gitops"
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
        "Description": "ArgoCD Description",
        "shortcut_text": "Argo CD",
        "shortcut_icon": "argocd.png",
        "swagger_docs_url": "https://{{componentName}}.{{baseDomain}}/swagger-ui",
        "api_docs_url": "https://argoproj.github.io/argo-cd/developer-guide/api-docs/",
        "vendor_docs_url": "https://argoproj.github.io/argo-cd/",
        "pre_install_scripts": [
            "installArgoCdCli.sh",
            "createArgoCdPassword.sh",
            "createIngressObjects.sh"
        ],
        "post_install_scripts": [
            "deployOauth2.sh"
        ]
    }
    ```

| 	Path Name                      | 	Description                                                                                                                                                                                                                                             | Example	                                                                       |
|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| 	installation_type	             | The installation method to use                                                                                                                                                                                                                           | 	argocd	                                                                       |
| 	helm_params.repository_url	    | The Helm repository path. Visit the vendor's helm manual to get the correct value                                                                                                                                                                        | 	`https://argoproj.github.io/argo-helm`	                                       |
| 	helm_params.repository_name	   | The Helm repository name. Visit the vendor's helm manual to get the correct value                                                                                                                                                                        | 	`argo/argo-cd`	                                                               |
| 	helm_params.helm_version	      | The version as defined in the `version` field in charts.yaml. This is an important value, to ensure the solution doesn't suddenly stop working due to an un-managed upgrade                                                                              | 	`4.10.5`	                                                                     |
| 	helm_params.set_key_values	    | An array of key:values pairs that are appended in `--set` fashion to the Helm installation command                                                                                                                                                       | 		                                                                             |
| 	helm_params.set_key_values[0]	 | An example of a set_key_value for ArgoCD. Notice the {{imageTag}} in use here. This is defined in the environment variables section above, and will automatically be replaced with the value of the environment variable during the installation process | 	`global.image.tag={{imageTag}}`	                                              |
| 	helm_params.set_key_values[1]	 | Another example of a set_key_value for Helm. This is optional. Alternatively, the entries can be added to `values_template.yaml` instead, which is recommended if a large number of key:values are needed                                                | installCRDs=false	                                                             |
| 	helm_params.set_key_values[2]	 | Another example of a set_key_value for Helm                                                                                                                                                                                                              | 	configs.secret<br/>.argocdServerAdminPassword=<br/>'{{argoCdAdminPassword}}'	 |
| 	helm_params.set_key_values[3]	 | Another example of a set_key_value for Helm                                                                                                                                                                                                              | 	controller.clusterAdminAccess<br/>.enabled=true	                              |
| 	helm_params.set_key_values[4]	 | Another example of a set_key_value for Helm                                                                                                                                                                                                              | 	server.clusterAdminAccess<br/>.enabled=true	                                  |
| 	helm_params.set_key_values[5]	 | Another example of a set_key_value for Helm                                                                                                                                                                                                              | 	server.extraArgs[0]=--insecure	                                               |




### ArgoCD

This section describes the settings needed to install an application via ArgoCD.

!!! note
    You must have installed ArgoCD before you can use this installation method

!!! tip
    If you also install Gitlab, you can automatically push code there and use that as the source repo url reference. See the [Grafana component](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/monitoring/grafana) for an example on how to do this. Here the two functions, `createGitlabProject` and `populateGitlabProject`, are used to achieve this.

As everything else is the same, the JSON example will be complete, but only the items not already described above will be described in more detail in the table below.

The ArgoCD installation process is executed via the following [script](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/functions/autoSetupArgoCdInstall.sh){:target="\_blank"}.

For general information on ArgoCD, visit their [docs site](https://argo-cd.readthedocs.io/en/stable/){:target="\_blank"}.

!!! example
    ```json
    {
        "name": "kx.as.code_docs",
        "namespace": "devops",
        "installation_type": "argocd",
        "installation_group_folder": "kx_as_code",
        "retry": "true",
        "argocd_params": {
            "repository": "{{gitUrl}}/kx.as.code/kx.as.code_docs.git",
            "path": "kubernetes",
            "dest_server": "https://kubernetes.default.svc",
            "dest_namespace": "devops",
            "sync_policy": "automated",
            "auto_prune": true,
            "self_heal": true
        },
        "categories": [
            "kx.as.code"
        ],
        "urls": [
            {
                "url": "https://docs.{{baseDomain}}",
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
        "Description": "KX.AS.CODE Docs Description",
        "shortcut_text": "KX.AS.CODE Docs",
        "shortcut_icon": "books.png",
        "pre_install_scripts": [
            "createGitProject.sh",
            "populateGitProject.sh",
            "buildAndPushDockerImage.sh"
        ],
        "post_install_scripts": []
    }
    ```

| 	Path Name	                    | Description                                                                                                 | 	Example	                                     |
|--------------------------------|-------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| 	installation_type	            | The installation method to use                                                                              | 	`argocd`	                                    |
| 	argocd_params.repository	     | The Git repository URL                                                                                      | 	`{{gitUrl}}/kx.as.code/kx.as.code_docs.git`	 |
| 	argocd_params.path	           | The path to the YAML files inside the repository                                                            | 	`kubernetes`	                                |
| 	argocd_params.dest_server	    | The Kubernetes cluster URL. Keep the standard for KX.AS.CODE                                                | 	`https://kubernetes.default.svc`	            |
| 	argocd_params.dest_namespace	 | Target Kubernetes namespace                                                                                 | 	`devops`	                                    |
| 	argocd_params.sync_policy	    | See the following [link](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/){:target="\_blank"} | 	`automated`	                                 |
| 	argocd_params.auto_prune	     | See the following [link](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/){:target="\_blank"} | 	`true`	                                      |
| 	argocd_params.self_heal	      | See the following [link](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/){:target="\_blank"} | 	`true`	                                      |

