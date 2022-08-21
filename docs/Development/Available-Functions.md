# Available Functions

The functions below can be used when creating scripts to install new solutions in the [auto-setup](https://github.com/Accenture/kx.as.code/tree/main/auto-setup){:target="\_blank"} folder.

!!! info 
    The core setup functions are used during the initial KX.AS.CODE deployment only, and should not be used for regular component installations, eg. those in the other category folders, such as cicd, collaboration, monitoring, and so on.

!!! tip
    You can override functions by copying them to the auto-setup/functions-custom folder. This is 
    recommended, to avoid upgrade issues in future.

    As well as overriding existing functions, new custom functions should also be dropped to the functions-custom folder.

    If you develop a new function that would be interesting to the wider community, then create a PR and lets add it to the main functions directory.

Here a quick table of contents, listing the function groups for easier navigation and overview.

1. [Application Deployments](../../Development/Available-Functions/#application-deployments)
2. [ArgoCD](../..//Development/Available-Functions/#argocd)
3. [Core Setup](../../Development/Available-Functions/#core-setup)
4. [Credential Management](../../Development/Available-Functions/#credential-management)
5. [Docker Registry](../../Development/Available-Functions/#docker-registry)
6. [General Helpers](../../Development/Available-Functions/#general-helpers)
7. [Gitlab](../../Development/Available-Functions/#gitlab)
8. [Harbor](../../Development/Available-Functions/#harbor)
9. [Keycloak IAM/SSO](../../Development/Available-Functions/#keycloak-iamsso)
10. [Kubernetes](../../Development/Available-Functions/#kubernetes)
11. [Logging](../../Development/Available-Functions/#logging)
12. [Mattermost](../../Development/Available-Functions/#mattermost)
13. [MinIO-S3](../../Development/Available-Functions/#minio-s3)
14. [Notifications](../../Development/Available-Functions/#notifications)
15. [RabbitMQ Core Setup](../../Development/Available-Functions/#rabbitmq-core-setup)

## Application Deployments

These functions are executed by the KX.AS.CODE [autoSetup.sh](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/autoSetup.sh){:target="\_blank"} auto-setup framework and do not need to be called individually by any of the custom component installation scripts.

### applicationDeploymentHealthCheck()
:material-git: Location: [auto-setup/functions/applicationDeploymentHealthCheck.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/applicationDeploymentHealthCheck.sh){:target="\_blank"}

This executes a health-check based on the application URL [0] found in the `metadata.json` of the component being installed.

!!! info
    There are no inputs to this function, as all the needed data comes from the component's `metadata.json`.

!!! tip
    Here an example extract from Gitlab's `metadata.json`
    The JSON below defines both the Kubernetes `liveliness` check and the `readiness` checks. You can read more about Kubernetes health probes [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request){:target="\_blank"}.
    This one defines the following:

    - URL path to access (will be appended to the base url)
    - Expected HTTP response  code
    - Expected JSON response text given json-path

    As you can see in the JSON, there are more options available. These will be described on another page, which describes in detail the contents of the `metadata.json`.

    ```json linenums="1"
    "urls": [
        {
            "url": "https://{{componentName}}.{{baseDomain}}",
            "healthchecks": {
                "liveliness": {
                    "http_path": "/-/readiness",
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
    ```

!!! note "Usage"
    `applicationDeploymentHealthCheck`

### autoSetupArgoCdInstall()
:material-git: Location: [auto-setup/functions/autoSetupArgoCdInstall.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/autoSetupArgoCdInstall.sh){:target="\_blank"}

!!! danger "Important"
    Note. You must deploy the `ArgoCD` application, before executing any component installations that depend on `ArgoCD`

!!! info 
    There are no inputs to this function, as all the needed data comes from the component's `metadata.json`.

!!! example
    Here an example snippet from a `metadata.json` for executing an application deployment with `ArgoCD`.

    The JSON below shows an example for deploying .

    The JSON shown here will described on another page, which describes in detail the contents of the `metadata.json`.
    Read up on [ArgoCD's core concepts](https://argo-cd.readthedocs.io/en/stable/core_concepts/){:target="\_blank"} to understand better the parameters below.

    ```json linenums="1"
    {
        "name": "myApp",
        "namespace": "devops",
        "installation_type": "argocd",
        "installation_group_folder": "kx_as_code",
        "argocd_params": {
            "repository": "{{gitUrl}}/kx.as.code/kx.as.code_docs.git",
            "path": "kubernetes",
            "dest_server": "https://kubernetes.default.svc",
            "dest_namespace": "devops",
            "sync_policy": "automated",
            "auto_prune": true,
            "self_heal": true
        }
    }
    ```

### autoSetupHelmInstall()
:material-git: Location: [auto-setup/functions/autoSetupHelmInstall.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/autoSetupHelmInstall.sh){:target="\_blank"}

!!! info 
    There are no inputs to this function, as all the needed data comes from the component's `metadata.json` and `values_template.yaml` file.

!!! example
    Here an example extract from ArgoCD's `metadata.json`"
    
    The JSON below defines the parameters needed to execute a deployment via helm. 

    The JSON is described in more detail on a page dedicated to `metadata.json`, so will only be described high level here.

    ```json linenums="1"
    {    
        "helm_params": {
            "repository_url": "https://argoproj.github.io/argo-helm",
            "repository_name": "argo/argo-cd",
            "helm_version": "4.2.1",
            "set_key_values": [
                "global.image.tag={{imageTag}}",
                "installCRDs=false",
                "configs.secret.argocdServerAdminPassword='{{argoCdAdminPassword}}'",
                "controller.clusterAdminAccess.enabled=true",
                "server.clusterAdminAccess.enabled=true",
                "server.extraArgs[0]=--insecure"
            ]
        }
    }
    ```

### autoSetupPreInstallSteps()
:material-git: Location: [auto-setup/functions/autoSetupPreInstallSteps.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/autoSetupPreInstallSteps.sh){:target="\_blank"}

Executes all the pre-install scripts as defined in `metadata.json` and located in the `pre_install_scripts` folder of the component in question.

### autoSetupScriptInstall()
:material-git: Location: [auto-setup/functions/autoSetupScriptInstall.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/autoSetupScriptInstall.sh){:target="\_blank"}

Executes all the main installation scripts as defined in `metadata.json` and located in the root folder of the component in question.
These scripts run after the pre and before the post installation scripts.

### createDesktopIcon()
:material-git: Location: [auto-setup/functions/desktopIconCreate.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/desktopIconCreate.sh){:target="\_blank"}

!!! note "Usage"
    `createDesktopIcon "<shortcutsDirectory>" "<primaryUrl>" "<shortcutText>" "<iconPath>" "<browserOptions>"`

!!! example
    ```bash linenums="1"
    # Install the desktop shortcut for KX.AS.CODE Portal
    shortcutsDirectory="/home/${vmUser}/Desktop"
    primaryUrl="http://localhost:3000"
    shortcutText="KX.AS.CODE Portal"
    iconPath="${installComponentDirectory}/$(cat ${componentMetadataJson} | jq -r '.shortcut_icon')"
    browserOptions=""
    createDesktopIcon "${shortcutsDirectory}" "${primaryUrl}" "${shortcutText}" "${iconPath}" "${browserOptions}"
    ```

### checkRunningKubernetesPods()
:material-git: Location: [auto-setup/functions/kubernetesCheckRunningPods.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/kubernetesCheckRunningPods.sh){:target="\_blank"}

This checks that the number of deployed pods equals the number of running pods for a given component installation. This is just a pre-check before proceeding onto the URL health checks.

### createKubernetesNamespace()
:material-git: Location: [auto-setup/functions/kubernetesCreateNamespace.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/kubernetesCreateNamespace.sh){:target="\_blank"}

!!! info "There are no inputs to this function, as all the needed data comes from the component's `metadata.json`."

### deployYamlFilesToKubernetes()
:material-git: Location: [auto-setup/functions/kubernetesDeployYamlFiles.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/kubernetesDeployYamlFiles.sh){:target="\_blank"}

Deploys all Kubernetes YAML files in the component's optional `deployment_yaml` directory.

`${installComponentDirectory}/deployment_yaml/*.yaml`

It also replaces all the `{{ mustache }}` placeholders in those YAML files with the values in global and component specific environment variables.

Finally, a validation check is done with [kubeval](https://kubeval.instrumenta.dev/){:target="\_blank"} to ensure the YAML file is valid before applying it. The function will exit with `RC=1` if a YAML file is found not to be valid.

## ArgoCD

### argoCdLogin()
:material-git: Location: [auto-setup/functions/argoCdLogin.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/argoCdLogin.sh){:target="_blank"}

Logs into ArgoCD before performing any ArgoCD specific actions.

!!! warning
    This function probably still works, but needs adjusting to take into account the new credential management process. 

!!! note "Usage"
    `argoCdLogin`

!!! example
    ```bash linenums="1"
    argoCdLogin
    ```

## Core Setup
These functions are called when KX.AS.CODE are first setup. They should not be needed in any of the auto-setup scripts that deploy applications on top of the base KX.AS.CODE setup. They were created to increase the readability of the code, not necessarily because the present blocks of code that will be needed repeatedly.

### populateActionQueuesJson()
:material-git: Location: [auto-setup/functions/actionQueuesPopulateJson.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/actionQueuesPopulateJson.sh){:target="\_blank"}

Creates a single `actionQueues.json` from all the group JSON templates and the core `acttionQueues.json`.

!!! note "Usage"
    `populateActionQueuesJson`

### populateActionQueuesRabbitMq()
:material-git: Location: [auto-setup/functions/populateActionQueuesRabbitMq.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/populateActionQueuesRabbitMq.sh){:target="\_blank"}

This function picks up the `actionQueues.json` and adds them to the RabbitMQ pending queue for processing.

!!! note "Usage"
    `populateActionQueuesRabbitMq`

### checkAndUpdateBasePassword()
:material-git: Location: [auto-setup/functions/checkAndUpdateBasePassword.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/checkAndUpdateBasePassword.sh){:target="\_blank"}

The default password is normally `L3arnandshare`. If this has been changed in the auto-setup.json (manually or via the configuration), then this function will change that to the target base password.

!!! note "Usage"
    `checkAndUpdateBasePassword`

### checkAndUpdateBaseUsername()
:material-git: Location: [auto-setup/functions/checkAndUpdateBaseUsername.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/checkAndUpdateBaseUsername.sh){:target="\_blank"}

The default username is normally `kx.hero`. If this has been changed in the auto-setup.json (manually or via the configuration), then this function will create a new user with the target base username.
The old username `kx.hero` will still be in the system, but not displayed at the login screen.

!!! note "Usage"
    `checkAndUpdateBaseUsername`

### checkGlusterFsServiceInstalled()
:material-git: Location: [auto-setup/functions/checkGlusterFsServiceInstalled.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/checkGlusterFsServiceInstalled.sh){:target="\_blank"}

Calling this function will check if a standalone KX.AS.CODE has been started. If so, it will automatically change any Kubernetes deployment files to use the `local-storage` storageClass, install of the `gluster-heketi` one.

!!! note "Usage"
    `checkGlusterFsServiceInstalled`

### configureBindDns()
:material-git: Location: [auto-setup/functions/configureBindDnsServer.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/configureBindDnsServer.sh){:target="\_blank"}

Sets up the domain names for base services and KX.AS.CODE administration tools, so that these can be called via their domain name, instead of `localhost:<port>`. 
Initial sub-domains setup by this function are:

| Domain Name | Purpose |
|---------------|----------------|
|pgadmin | Starts PGAdmin. Postgres is primarily used for the Guacamole setup. May be useful for debugging.|
|kx-main1| The IP address of the main node. The first main node is the overall controller.|
|ldap| For accessing openldap, which is used as the basis for SSO.|
|ldapadmin| Domain for the LDAP account manager -> https://sourceforge.net/projects/lam/ |
|rabbitmq| Domain for RabbitMQ Mgmt UI -> https://www.cloudamqp.com/blog/part3-rabbitmq-for-beginners_the-management-interface.html|
|remote-desktop| Domain for the Guacamole Remote Desktop -> https://guacamole.apache.org/ |
|api-internal| For accessing the Kubernetes API endpoints|
|\*| For directing all Kubernetes deployed applications to the Kubernetes NGINX Ingress Controller|

!!! note "Usage"
    `configureBindDns`

### configureKeyboardSettings()
:material-git: Location: [auto-setup/functions/configureKeyboard.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/configureKeyboard.sh){:target="\_blank"}

Configures the default keyboard for the user.
Currently the installed languages are:

| Language | Code |
|---------------|----------------|
|English (USA) |us |
|de|German|
|gb| English (British)|
|fr| French|
|it| Italian|
|es| Spanish|

The languages can be customized after initial KX.AS.CODE setup, using either standard Linux CLI commands or using the desktop control panel.
If there is enough demand for another language to be added to the base setup, we can do that in future. Currently in the BETA we have a small set of languages for debugging and testing.

!!! note "Usage"
    `configureKeyboardSettings`

### configureNetwork()
:material-git: Location: [auto-setup/functions/configureNetwork.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/configureNetwork.sh){:target="\_blank"}

Configures the network of the main or node VMs when they come up. If `fixed` IP addresses have been set in the `profile-config.json`, these will be configured in the virtual NICs. If not, an IP address will be retrieved via DHCP.
For DNS there are 2 options. `hybrid` and `fixed`. Hybrid will configure the NICs with both the dynamically retrieved DNS servers, as well as the local BIND DNS.
Fixed will set the DNS servers configured in `profile-config.json` only. 

!!! danger "Important" 
    Important, in the case of a fixed DNS setting, ensure that the first one points to the IP of KX-Main1.

The KX.AS.CODE virtualization profiles are currently setup as follows:

|Virtualization|IP Address| DNS|
|---|---|---|
|AWS |Single NIC with dynamic IP address|Hybrid|
|OpenStack |Single NIC with dynamic IP address|Hybrid|
|Parallels|Single NIC with dynamic IP address|Hybrid|
|VirtualBox|Two NICs with fixes IP addresses. First is a NAT interface with default VirtualBox IP `10.0.2.15`. The second IP used a custom "kxascode" network with IP `10.100.76.x`, unless changes, likely to be `10.100.76.200`. Kubernetes is configured to listen to the second NIC, otherwise the hosts will not be able to talk to each other.|Fixed|
|VMWare|Single NIC with dynamic IP address|Hybrid|

!!! note "Usage"
    `configureNetwork`

### createExternalAccessDirectory()
:material-git: Location: [auto-setup/functions/createExternalAccessDirectory.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/createExternalAccessDirectory.sh){:target="\_blank"}

Creates directory `/vagrant/kx-external-access` (if local virtualization is in use) or `/kx-external-access` if private or public cloud. This directory will eventually contain the hosts file and the KX.AS.CODE certificates, which can be used to access the deployed applications outside of the VM.

!!! note "Usage"
    `createExternalAccessDirectory`

!!! example
    ```bash linenums="1"
    createExternalAccessDirectory
    ```

### disableLinuxDesktop()
:material-git: Location: [auto-setup/functions/disableLinuxDesktop.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/disableLinuxDesktop.sh){:target="\_blank"}

If disableLinuxDesktop was set to true in `profile-config.json`, this will disable the desktop during the initial KX.AS.CODE setup on first start abd reboot into the CLI. 
!!! tip 
    A script is dropped into `usr/share/kx.as.code/workspace` for re-enabling the desktop. Alternatively, it is also possible enter `startx` at the command line, to temporarily enable the desktop, but keep the default configuration.

!!! note "Usage"
    `disableLinuxDesktop`

### getComponentInstallationProperties()
:material-git: Location: [auto-setup/functions/getComponentInstallationProperties.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getComponentInstallationProperties.sh){:target="\_blank"}

Sets up the base parameters for the component in `auto-setup` being installed. All installation scripts should reference these standard variables, in order to ensure the solution continues functioning in future, if for example, there was a change to the base `auto-setup` directory structure. 
Variables exported as shell environment variables for use in scripts are the following:

| Variable name | Description |
| --- | --- |
| installComponentDirectory | The full path to the components home folder being installed|
| componentMetadataJson | Complete JSON block from the components `metadata.json` file |
| namespace | Kubernetes namespace. Ignored if not defined in `metadata.json` for solution being installed|
| installationType  | argocd, helm or script|
| applicationUrl | Used for health checks|
| applicationDomain | Application URL & domain |

As well as the above, all environment variables defined in `metadata.json` are also exported for use as bash environment variables, or for replacing placeholders in configuration files using the mustasch syntax -> `{{ variable_name}}`

!!! note "Usage"
    `getComponentInstallationProperties`

### getGlobalVariables()
:material-git: Location: [auto-setup/functions/getGlobalVariables.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getGlobalVariables.sh){:target="\_blank"}

Exposes all global variables in `auto-setup/globalVariables.json`, so that they can be referenced  in scripts.
!!! info 
    Currently the variables defined in `globalVariables.json` are the following:
    ```json linenums="1"
    {
    "sharedKxHome": "/usr/share/kx.as.code",
    "installationWorkspace": "${sharedKxHome}/workspace",
    "certificatesWorkspace": "${installationWorkspace}/certificates",
    "actionWorkflows": "pending wip completed failed retry notification",
    "defaultDockerHubSecret": "default/regcred",
    "sharedGitHome": "${sharedKxHome}/git",
    "autoSetupHome": "${sharedGitHome}/kx.as.code/auto-setup",
    "skelDirectory": "${sharedKxHome}/skel",
    "vendorDocsDirectory": "${sharedKxHome}/Vendor Docs",
    "apiDocsDirectory": "${sharedKxHome}/API Docs",
    "shortcutsDirectory": "${sharedKxHome}/Applications",
    "devopsShortcutsDirectory": "${sharedKxHome}/Applications",
    "adminShortcutsDirectory": "${sharedKxHome}/Admin Tools",
    "vmUser": "kx.hero",
    "vmUserId": "$(id -u ${vmUser})",
    "vmPassword": "$(cat ${sharedKxHome}/.config/.user.cred)"
    }
    ```

!!! note "Usage"
    `getGlobalVariables`

### getNetworkConfiguration()
:material-git: Location: [auto-setup/functions/getNetworkConfiguration.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getNetworkConfiguration.sh){:target="\_blank"}

Get the network interfaces installed on the system. In most cases there will be only one NIC defined, but in the case of VirtualBox, there are two.
This script ensures that subsequent scripts know which NICs to avoid listening on, eg, the VirtualBox NAT NIC with IP `10.0.2.15`.

!!! note "Usage"
    ``

### getProfileConfiguration()
:material-git: Location: [auto-setup/functions/getProfileConfiguration.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getProfileConfiguration.sh){:target="\_blank"}

??? info "Example profile-config.json file (click to expand)"
    Here is an example profile-config.json file, which will be read and exported to environment variables.    
    ```json linenums="1"
    {
        "config": {
            "allowWorkloadsOnMaster": "false",
            "baseDomain": "kx-as-code.local",
            "baseIpType": "static",
            "basePassword": "L3arnandshare",
            "baseUser": "kx.hero",
            "certificationMode": false,
            "defaultKeyboardLanguage": "de",
            "disableLinuxDesktop": "false",
            "disableSessionTimeout": true,
            "dnsResolution": "static",
            "docker": {
                "dockerhub_email": "",
                "dockerhub_password": "",
                "dockerhub_username": ""
            },
            "environmentPrefix": "demo1",
            "glusterFsDiskSize": 200,
            "local_volumes": {
                "fifty_gb": 0,
                "five_gb": 15,
                "one_gb": 15,
                "ten_gb": 15,
                "thirty_gb": 0
            },
            "metalLbIpRange": {
                "ipRangeEnd": "10.10.76.150",
                "ipRangeStart": "10.10.76.100"
            },
            "proxy_settings": {
                "http_proxy": "",
                "https_proxy": "",
                "no_proxy": ""
            },
            "selectedTemplates": "CICD Group 1",
            "sslProvider": "self-signed",
            "standaloneMode": "true",
            "startupMode": "normal",
            "staticNetworkSetup": {
                "baseFixedIpAddresses": {
                    "kx-main1": "10.100.76.200",
                    "kx-main2": "10.100.76.201",
                    "kx-main3": "10.100.76.202",
                    "kx-worker1": "10.100.76.203",
                    "kx-worker2": "10.100.76.204",
                    "kx-worker3": "10.100.76.205",
                    "kx-worker4": "10.100.76.206"
                },
                "dns1": "10.100.76.200",
                "dns2": "8.8.8.8",
                "gateway": "10.100.76.2"
            },
            "virtualizationType": "local",
            "vm_properties": {
                "3d_acceleration": "off",
                "main_admin_node_cpu_cores": 4,
                "main_admin_node_memory": 8192,
                "main_node_count": 1,
                "main_replica_node_cpu_cores": 2,
                "main_replica_node_memory": 8192,
                "worker_node_count": 2,
                "worker_node_cpu_cores": 4,
                "worker_node_memory": 8192
            }
        }
    }
    ```
The above JSON fields are exported to the following variables:

| Variable name | Variable Group | Description | Possible Values |
| --- | --- | --- | --- |
|virtualizationType|General|The type of virtualization. Setting a cloud for example, will affect how Grub is setup.|`private_cloud`, `public_cloud`, `local_virtualization`|
|standaloneMode|Base Setup|This will ensure that some configuration changes are applied when installing components in auto-setup. For example, glusterfs is not installed, and components requiring glusterfs are automatically changed to use local-storage instead. |`true` or `false`|
|baseIpType|Network Setup|For most virtualization profiles this is set to `dynamic`. Only VirtualBox is `static`.|`static` or `dynamic`|
|dnsResolution|Network Setup|Must be set to `fixed` if baseIpType is set to `static`. Set to `hybrid` if `baseIpType` is set to `dynamic`. This will append the local BindDNS instance IP to `resolv.conf`, to the DNS servers retrieved from DHCP|`fixed` or `hybrid`|
|mainIpAddress|Network Setup|This is set dynamically by querying the local system, or if the IP type was set to fixed, by extracting the IP for `kx-main1` from `profile-config.json`|`<kx-main1's IP address>`|
|fixedNicConfigGateway|Network Setup|Only read if the `baseIpType` is set to `static`. This will set the NIC's gateway, when applying the static IP configuration defined in `profile-config.json`|`<kx-main1's IP gateway address>`|
|fixedNicConfigDns1|Network Setup|Only read if the `baseIpType` is set to `static`. This will set the NIC's DNS1 resolver (should be set to `kx-main1`'s IP address), when applying the static IP configuration defined in `profile-config.json`|`<kx-main1's IP address>`|
|fixedNicConfigDns2|Network Setup|Only read if the `baseIpType` is set to `static`. This will set the NIC's DNS2 resolver (can be anything, such as `8.8.8.8`, when applying the static IP configuration defined in `profile-config.json`||
|environmentPrefix|Base FQDN|This will be prepended to the `baseDomain` to create the KX.AS.CODE environment's FQDN. This is useful when deploying several KX.AS.CODE installations||
|baseDomain|Base FQDN|This will be appended to the `environmentPrefix` to create the KX.AS.CODE environment's FQDN. This is useful when deploying several KX.AS.CODE installations||
|baseDomainWithHyphens|Base FQDN|Used in some component configurations, where periods break the components installation process|<i>automatically generated</i>|
|numKxMainNodes|Base Setup|Used for some core processing where the number of nodes is relevant to the operations||
|defaultKeyboardLanguage|Base Setup|The default language for the VM. |`us`,`de`,`gb`,`fr`,`it`,`es`|
|baseUser|Base Setup|The base user|default is `kx.hero` if not changed|
|basePassword|Base Setup|The password for the base user|default is `Learnandshare` if not changed|
|baseIpRangeStart|<i>currently not used</i>|<i>currently not used</i>||
|baseIpRangeEnd|<i>currently not used</i>|<i>currently not used</i>||
|metalLbIpRangeStart|Load Balancing|Sets the start of the IP range dynamically allocated by the Kubernetes MetalLB controller||
|metalLbIpRangeEnd|Load Balancing|Sets the end od the IP range dynamically allocated by the Kubernetes MetalLB controller||
|sslProvider|SSL||`self-signed` or `letsencrypt`|
|sslDomainAdminEmail|SSL|Sets the LetsEncrypt admin email for receiving expiration notifications etc. Only needed when LetsEncrypt is enabled (`sslProvider=letsencryt`)|`<valid email address>`|
|letsEncryptEnvironment|SSL|This is used when installing the cert-manager into Kubernetes, to determine which LetsEncrypt provider to use. Only needed when LetsEncrypt is enabled (`sslProvider=letsencryt`)|`prod` or `staging`|
|httpProxySetting|HTTP Proxy|HTTPS URL to proxy. KX.AS.CODE works best without a proxy.|`<hostname>:<port>`|
|httpsProxySetting|HTTP Proxy|HTTP URL to proxy KX.AS.CODE works best without a proxy.|`<hostname>:<port>`|
|noProxySetting|HTTP Proxy|IP addresses or ranges that should not be accessed via the proxy|IP ranges/addresses separated by a commma|

!!! note "Usage"
    `getProfileConfiguration`

### getVersions()
:material-git: Location: [auto-setup/functions/getVersions.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getVersions.sh){:target="\_blank"}

The Kubernetes and KX.AS.CODE versions are exported to `kxVersion` and `kubeVersion` environment variables.

!!! note "Usage"
    `getVersions`

### gnupgInitializeUser()
:material-git: Location: [auto-setup/functions/gnupgInitializeUser.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gnupgInitializeUser.sh){:target="\_blank"}

[gnupg](https://www.gnupg.org/){:target="\_blank"} is initialized for the GoPass setup later on.

!!! note "Usage"
    `gnupgInitializeUser`

### installEnvhandlebars()
:material-git: Location: [auto-setup/functions/installEnvhandlebars.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/installEnvhandlebars.sh){:target="\_blank"}

In some cases, [mo](https://mustache.github.io/){:target="\_blank"} is used for replacing `{{ mustache }}` placeholders in templates. However, when there needs to be more advanced processing, eg. for escaping a curl bracket, the node [envhandlebars](https://www.npmjs.com/package/envhandlebars){:target="\_blank"} utility is used instead.
This function installs `envhandlebars`. 

!!! note "Usage"
    `installEnvhandlebars`

### executePostInstallScripts()
:material-git: Location: [auto-setup/functions/postInstallExecuteScripts.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/postInstallExecuteScripts.sh){:target="\_blank"}

Executes a component's post installation scripts.

!!! note "Usage"
    `executePostInstallScripts`

### postInstallStepLetsEncrypt()
:material-git: Location: [auto-setup/functions/postInstalllStepLetsEncrypt.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/postInstalllStepLetsEncrypt.sh){:target="\_blank"}

Updates a component's [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/){:target="\_blank"} resource, to use the LetsEncrypt SSL provider, if the variable `sslProvider` is set to `letsencrypt`.

!!! note "Usage"
    `executePostInstallScripts`

### setLogFilename()
:material-git: Location: [auto-setup/functions/setLogFilename.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/setLogFilename.sh){:target="\_blank"}

Sets an individual log file name for each component installation.

`${installationWorkspace}/${componentName}_${logTimestamp}.${retries}.log`

If a component installation is not in progress, the generic logfile name is used:
`${installationWorkspace}/kx.as.code_autoSetup.log`

!!! note "Usage"
    `setLogFilename`

### updateHostFileForExternalUse()
:material-git: Location: [auto-setup/functions/updateHostFileForExternalUse.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/updateHostFileForExternalUse.sh){:target="\_blank"}

This function is automatically run with every application install. It makes all configured Kubernetes ingress endpoints available in the kx-external-access directory. See also the function `createExternalAccessDirectory()`.    

!!! note "Usage"
    updateHostFileForExternalUse
    ``

!!! example
    ```bash linenums="1"
    updateHostFileForExternalUse
    ```

### updateKxSourceOnFirstStart()
:material-git: Location: [auto-setup/functions/updateKxSourceOnFirstStart.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/updateKxSourceOnFirstStart.sh){:target="\_blank"}

Dependent on a flag set in profile-config.json, the KX.AS.CODE source will be uppdated from Git on first start, to ensure any critical fixes are pulled since the last official release. This saves needing to rebuild the entire image with every minor release, and also ensures the user does not need to upgrade their KX.AS.CODE machine for a minor fix.

!!! note "Usage"
    `updateKxSourceOnFirstStart`

!!! example
    ```bash linenums="1"
    updateKxSourceOnFirstStart
    ```

### updateStorageClassIfNeeded()
:material-git: Location: [auto-setup/functions/updateStorageClassIfNeeded.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/updateStorageClassIfNeeded.sh){:target="\_blank"}

Detects if `glusterfs` is installed or not. If not, this function automatically updates the `helm` and `Kubernetes` configuration files for the component to use the `local-storage` [storageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/){:target="\_blank"} instead of `gluster-heketi`.

!!! note "Usage"
    `updateStorageClassIfNeeded`

### waitForMessageOnActionQueue()
:material-git: Location: [auto-setup/functions/waitForMessageOnActionQueue.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/waitForMessageOnActionQueue.sh){:target="_blank"}

Waits for the message to actually be available on the target RabbitMQ queue, before proceeding with the next step.

!!! note "Usage"
    `waitForMessageOnActionQueue <queue_name> <application>`

!!! example
    ```bash linenums="1"
    waitForMessageOnActionQueue "retry_queue" "${componentName}"
    ```

## Credential Management

### deletePassword()
:material-git: Location: [auto-setup/functions/passwordDelete.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/passwordDelete.sh){:target="_blank"}

Deletes a password from GoPass.

The password group is only needed if the password was created with a password group. In GoPass, the password group is shown as a folder under the domain name.

!!! note "Usage"
    `deletePassword "<pasword name in GoPass>" "<password group>"`

!!! example
    ```bash linenums="1"
    deletePassword "gitlab-root-user" gitlab"
    ```

### generateApiKey()
:material-git: Location: [auto-setup/functions/apiKeyGenerate.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/apiKeyGenerate.sh){:target="\_blank"}

!!! hint 
    Best just to use `apiKeyManage`, which does all the get, generate and push in one go, with validation checks etc

Generates a 32 character string that is API compatible. eg. no special characters - just alpha-numeric characters.

!!! note "Usage"
    `apiKeyGenerate`

!!! example
    ```bash linenums="1"
    export apiKey=$(apiKeyGenerate)
    ```

### managedApiKey()
:material-git: Location: [auto-setup/functions/apiKeyManage.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/apiKeyManage.sh){:target="\_blank"}

This generates a key using the `apiKeyGenerate` function if it does not already exist in [GoPass](https://github.com/gopasspw/gopass){:target="\_blank"}, and then pushes it go [GoPass](https://github.com/gopasspw/gopass){:target="\_blank"} with `passwordPush`.
Saves the developer the hassle of making several calls and writing their own validations.
This checks if the api key is already in GoPass, and creates it if not, subsequently returning it. If it already exists, the API key is retrieved from GoPass and again, returned.

!!! note "Usage"
    `apiKeyManage "<name of api key>" "<password group>"`

!!! example
    ```bash linenums="1"
    export apiKey=$(managedApiKey "gitlab-api-key" "gitlab")
    ```


### generatePassword()
:material-git: Location: [auto-setup/functions/passwordGenerate.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/passwordGenerate.sh){:target="\_blank"}

!!! hint
    Best just to use `passwordManage`, which does all the get, generate and push in one go, with validation checks etc

Generates a 32 character string with special characters. Mostly used to create a secure password for admin users created during the component `auto-setup` installations.
To keep issues to a minimum with special characters, only the following special characters are included.
`{A..Z} {a..z} {0..9} {0..9} '# % * _ + - .`

!!! warning
    Ensure that the password variable is quoted in the configuration files! This can easily break the installation if there is a character that bash does not handle correctly if not quotes. Also, be careful when using this to generate passwords for databases. For API keys, you should use `apiKeyGenerate` instead.

### getPassword()
:material-git: Location: [auto-setup/functions/passwordGet.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/passwordGet.sh){:target="\_blank"}

!!! hint 
    Best just to use `passwordManage`, which does all the get, generate and push in one go, with validation checks etc

Gets the password as stored in GoPass by passing the name of the password generated previously.

!!! note "Usage"
    `passwordGet "<name of password>" "<password group>"`

!!! example
    ```bash linenums="1"
    export password=$(passwordGet "gitlab-root-password" "gitlab")
    ```

### managedPassword()
:material-git: Location: [auto-setup/functions/passwordManage.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/passwordManage.sh){:target="\_blank"}

Saves the developer the hassle of making several calls and writing their own validations.
This checks if the password is already in GoPass, and creates it if not, subsequently returning it. If it already exists, the password is retrieved from GoPass and again, returned. 

!!! note "Usage"
    `passwordManage "<name of password>" "<password group>"`

!!! example
    ```bash linenums="1"
    export password=$(passwordManage "gitlab-root-password" "gitlab")
    ```

### pushPassword()
:material-git: Location: [auto-setup/functions/passwordPush.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/passwordPush.sh){:target="\_blank"}

!!! hint 
    Best just to use `passwordManage`, which does all the get, generate and push in one go, with validation checks etc

Pushes the password to GoPass. 

!!! note "Usage"
    `passwordPush "<name of password>" "<password>" "<password group>"`

!!! example
    ```bash linenums="1"
    password=$(generatePassword))
    passwordPush "gitlab-root-password" "${password} "gitlab"
    ```

### renewApiKey()
:material-git: Location: [auto-setup/functions/apiKeyRenew.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/apiKeyRenew.sh){:target="_blank"}

Renews the specified API key.

!!! note "Usage"
    `renewApiKey "<pasword name>" "<password group>"`

!!! example
    ```bash linenums="1"
    renewApiKey "gitlab-personal-access-token" "gitlab"
    ```

## Docker Registry

The functions here are for managing the standard [docker registry](https://hub.docker.com/_/registry){:target="\_blank"} installed as part of the [core setup](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/docker-registry){:target="\_blank"}.

### dockerRegistryAddUser()
:material-git: Location: [auto-setup/functions/dockerCoreRegistryAddUser.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/dockerCoreRegistryAddUser.sh){:target="\_blank"}

Creates or updates the Kubernetes secret containing the `htpasswd` file containing username and passwords, in the Docker Registry namespace, and remounts into the docker-registry pod, subsequently redeploying the POD with a rolling update.

!!! note "Usage"
    `dockerRegistryAddUser "<username>"`

### createK8sCredentialSecretForCoreRegistry()
:material-git: Location: [auto-setup/functions/dockerCoreRegistryK8sCredential.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/dockerCoreRegistryK8sCredential.sh){:target="\_blank"}

Creates the regCred secret needed by other deployments for pulling images from the private core docker registry.
The secret is created in the Kubernetes namespace of the current solution being installed.

!!! note "Usage"
    `createK8sCredentialSecretForCoreRegistry`

### loginToCoreRegistry()
:material-git: Location: [auto-setup/functions/dockerCoreRegistryLogin.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/dockerCoreRegistryLogin.sh){:target="\_blank"}

!!! tip 
    This is usually carried out by the other docker-registry functions, and rarely needs to be called directly.

!!! note "Usage"
    `loginToCoreRegistry`

Logs into the KX.AS.CODE docker registry. Needed before executing any other actions against the registry.


### pushDockerImageToCoreRegistry()
:material-git: Location: [auto-setup/functions/dockerCoreRegistryPush.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/dockerCoreRegistryPush.sh){:target="\_blank"}

Pushes a built image to the KX.AS.CODE core docker registry.

!!! note "Usage"
    `pushDockerImageToCoreRegistry "<docker image path>:<tag>"`

!!! example
    ```bash linenums="1"
    docker build -f ${installationWorkspace}/Dockerfile.Docker-Dind -t docker-registry.${baseDomain}/devops/docker:${gitlabDindImageVersion} .
    pushDockerImageToCoreRegistry "devops/docker:${gitlabDindImageVersion}"
    ```

## General Helpers

### checkApplicationInstalled()
:material-git: Location: [auto-setup/functions/checkApplicationInstalled.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/checkApplicationInstalled.sh){:target="_blank"}

Checks if a given application is installed or not. This is important for application installations that rely on other solutions to be available. For example, if the configuration needs Mattermost to be installed before creating a notification webhook, this part of the installation process could be skipped if the application is not installed, rather than failing the whole installation, due to a missing dependency.

!!! note "Usage"
    `checkApplicationInstalled "<application name>" "<application category folder>"`

!!! example
    ```bash linenums="1"
    checkApplicationInstalled "gitlab" "cicd"
    ```

### functionStart()
:material-git: Location: [auto-setup/functions/functionStart.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/functionStart.sh){:target="_blank"}

Is called at the start of each function. Include common steps such as enabling debug logging.

!!! note "Usage"
    `functionStart`

!!! example
    ```bash linenums="1"
    functionStart
    ```

### functionEnd()
:material-git: Location: [auto-setup/functions/functionEnd.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/functionEnd.sh){:target="_blank"}

Is called at the start of each function. Include common steps such as disabling debug logging.

!!! note "Usage"
    `functionEnd`

!!! example
    ```bash linenums="1"
    functionEnd
    ```

### getCpuArchitecture()
:material-git: Location: [auto-setup/functions/getCpuArchitecture.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getCpuArchitecture.sh){:target="_blank"}

Sets the global `cpuArchitecture` variable to either `amd64` or `arm64`. This can then be used in scripts to decide which version of a binary ot install.

!!! note "Usage"
    `getCpuArchitecture`

!!! example
    ```bash linenums="1"
    getCpuArchitecture
    ```

### getNginxControllerIp()
:material-git: Location: [auto-setup/functions/getNginxControllerIp.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/getNginxControllerIp.sh){:target="_blank"}

!!! note "Usage"
    `nginxIngressIp`

!!! example
    ```bash linenums="1"
    # Function returns the NGINX Ingress Controller's IP address. You will need to export the returned result to a variable.
    export nginxIngressIp=$(getNginxControllerIp)
    ```

### roundUp()
:material-git: Location: [auto-setup/functions/arithmeticRoundUp.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/arithmeticRoundUp.sh){:target="\_blank"}

This rounds a number up rather than down, when a value if x.5. This was created to fix a mismatch between the calculation done in Ruby (the Vagrantfile), and later the same calculation in bash.

!!! note "Usage"
    `roundUp <floating point number>`

### checkDockerHubRateLimit()
:material-git: Location: [auto-setup/functions/dockerhubCheck.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/dockerhubCheck.sh){:target="\_blank"}

Since Docker Hub limited the number of downloads for anonymous and fee account users, this function is called before every component installation, to make sure the user is not close to the limit (<25), or the limit is used  up (0 download remaining).
Either find will result in a warning or error message respectively. This is to help the user understand why component installations may be failing due to image pull failures.

To solve this, a user can add their docker hub credentials to profile-config.json.

More details on the Docker Hub download rate limit can be found on the following [link](https://docs.docker.com/docker-hub/download-rate-limit/){:target="\_blank"}.

### downloadFile()
:material-git: Location: [auto-setup/functions/downloadFile.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/downloadFile.sh){:target="\_blank"}

!!! note "Usage"
    `downloadFile "<file url>" "<sha256sum checksum>" "<output_filename>"`

If the output filename is not provided, the filename provided in the URL will be used instead.

It is recommended to add the `version` and `checksum` to the component's `metadata.json` as environment variables, and then reference those in the installation script, rather than hard coding both.

!!! example
    
        metadata.json:
        ```json linenums="1"
        {
            "environment_variables": {
                "guacamoleVersion": "1.3.0",
                "guacamoleChecksum": "bc5511c7170841f90d437b5a07b7ec2f5bfd061f2a5bfc4e4d0fc4d7b303fb4c"
            }
        }
        ```
    script:
    ```bash linenums="1"
    # Download, build, install and enable Guacamole
    downloadFile "https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${guacamoleVersion}/source/guacamole-server-${guacamoleVersion}.tar.gz" \
        "${guacamoleChecksum}" \
        "${installationWorkspace}/guacamole-server-${guacamoleVersion}.tar.gz" && log_info "Return code received after downloading guacamole-server-${guacamoleVersion}.tar.gz is $?"
    ```

### waitForFile()
:material-git: Location: [auto-setup/functions/waitForFile.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/waitForFile.sh){:target="\_blank"}

Waits for a file to be at a given location. This is useful is a file is required before a next step in an installation process can be triggered, but is not available until other processing is completed.

!!! note "Usage"
    `waitForFile "<absolute path to file>"`

### checkUrlHealth()
:material-git: Location: [auto-setup/functions/urlHealthCheck.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/urlHealthCheck.sh){:target="\_blank"}

!!! note "Usage"
    `checkUrlHealth "<url>" "<expected http response code>" "<basic authentication>"`

Basic authentication must have the form `"<username>:<password>"`. Basic authentication is optional. It is recommended to use the `managedPassword` function to store and retrieve the password securely.
The `URL` and expected `RC` are mandatory.

!!! example
    ```bash linenums="1"
    # Call running KX-Portal to check status and pre-compile site
    checkUrlHealth "http://localhost:3000" "200"
    ```

## Gitlab

Functions for interacting with the Gitlab API. Currently just 2 functions. These will be expanded in future.

### createGitlabProject()
:material-git: Location: [auto-setup/functions/gitlabCreateProject.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabCreateProject.sh){:target="\_blank"}

Create a new project in Gitlab.

!!! note "Usage"
    `createGitlabProject "<project name>" "<group name>"`

!!! example
    ```bash linenums="1"
    createGitlabProject "grafana-image-renderer" "devops"
    ```

### gitlabCreateGroup()
:material-git: Location: [auto-setup/functions/gitlabCreateGroup.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabCreateGroup.sh){:target="_blank"}

Create a group in Gitlab.

!!! note "Usage"
    `gitlabCreateGroup "<group name>"`

!!! example
    ```bash linenums="1"
    gitlabCreateGroup "kx.as.code"
    ```

### gitlabCreateGroupVariable()
:material-git: Location: [auto-setup/functions/gitlabCreateGroupVariable.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabCreateGroupVariable.sh){:target="_blank"}

Add a group variable for use in CICD pipelines.

!!! note "Usage"
    `gitlabCreateGroupVariable "<variable name>" "<variable key>" "<variable value>"`

!!! example
    ```bash linenums="1"
    gitlabCreateGroupVariable "REGISTRY_ROBOT_PASSWORD" "${kxRobotToken}" "${kxascodeGroupId}"
    ```

### gitlabCreateUser()
:material-git: Location: [auto-setup/functions/gitlabCreateUser.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabCreateUser.sh){:target="_blank"}

Create a user in Gitlab.

!!! note "Usage"
    `gitlabCreateUser "<username>"`

!!! example
    ```bash linenums="1"
    gitlabCreateUser "joe.bloggs"
    ```


### gitlabGetGroupId()
:material-git: Location: [auto-setup/functions/gitlabGetGroupId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabGetGroupId.sh){:target="_blank"}

Get the id of an existing user in Gitlab.

Get the id of an available group in Gitlab

!!! note "Usage"
    `gitlabGetGroupId "<gitlab group>"`

!!! example
    ```bash linenums="1"
    gitlabGroupId=$(gitlabGetGroupId "kx.as.code")
    ```

### gitlabGetUserId()
:material-git: Location: [auto-setup/functions/gitlabGetUserId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabGetUserId.sh){:target="_blank"}

Get the id of an available user in Gitlab

!!! note "Usage"
    `gitlabGetUserId "<gitlab username>"`

!!! example
    ```bash linenums="1"
    gitlabUserId=$(gitlabGetUserId "joe.bloggs")
    ```

### gitlabMapUserToGroup()
:material-git: Location: [auto-setup/functions/gitlabMapUserToGroup.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabMapUserToGroup.sh){:target="_blank"}

Map a user to a group in Gitlab

!!! note "Usage"
    `gitlabMapUserToGroup "<gitlab username>" "<gitlab group name>"`

!!! example
    ```bash linenums="1"
    gitlabMapUserToGroup "joe.bloggs" "kx.as.code"
    ```

### populateGitlabProject()
:material-git: Location: [auto-setup/functions/gitlabPopulateProject.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/gitlabPopulateProject.sh){:target="\_blank"}

Populate a project in Gitlab with source code from a given directory.

!!! note "Usage"
    `populateGitlabProject "<gitlabProjectName>" "<gitlabRepoName>" "<sourceCodeLocation>"`

!!! example
    ```bash linenums="1"
    populateGitlabProject "devops" "grafana-image-renderer" "${autoSetupHome}/monitoring/grafana/deployment_yaml"
    ```

## Harbor

### harborCreateProject()
:material-git: Location: [auto-setup/functions/harborCreateProject.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/harborCreateProject.sh){:target="_blank"}

Create a new project in Harbor.

!!! note "Usage"
    `harborCreateProject "<harbor project name>"`

!!! example
    ```bash linenums="1"
    harborCreateProject "kx-as-code"
    ```

### harborCreateRobotAccount()
:material-git: Location: [auto-setup/functions/harborCreateRobotAccount.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/harborCreateRobotAccount.sh){:target="_blank"}

Create a robot account for use in CICD pipelines.

!!! note "Usage"
    `harborCreateRobotAccount "<project id>" "<robot id name>" "<robot id short description>"`

!!! example
    ```bash linenums="1"
    # Get Harbor Project Ids
    export kxHarborProjectId=$(harborGetProjectId "kx-as-code")
    # Create Harbor robot account
    harborCreateRobotAccount "${kxHarborProjectId}" "kx-cicd-user" "KX.AS.CODE CICD User"
    ```

### harborGetProjectId()
:material-git: Location: [auto-setup/functions/harborGetProjectId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/harborGetProjectId.sh){:target="_blank"}

Get the id of a previously created project.

!!! note "Usage"
    `harborGetProjectId "<harbor project name>"`

!!! example
    ```bash linenums="1"
    export kxHarborProjectId=$(harborGetProjectId "kx-as-code")
    ```


## Keycloak IAM/SSO
These functions were generated to avoid repeating the same code for each component connected to Keycloak IAM/SSO.
For general documentation on how Keycloak IAM/SSO works, read the following [documentation](https://www.keycloak.org/docs/latest/securing_apps/).
??? abstract "Examples for using enableKeycloakSSOForSolution()"
    In most situations, it should be enough to call `enableKeycloakSSOForSolution()` to create the SSO configuration in Keycloak for the respective component installation. Only in rare cases is this not possible, due to the particularities of the component for which SSO is being enabled. Expand this box to see examples.

    !!! example

        [Harbor Registry](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/cicd/harbor/post_install_scripts/deployOidc.sh){:target="\_blank"}

        ```bash linenums="1" hl_lines="8"
        # Integrate solution with Keycloak
        redirectUris="https://${componentName}.${baseDomain}/c/oidc/callback"
        rootUrl="https://${componentName}.${baseDomain}"
        baseUrl="/applications"
        protocol="openid-connect"
        fullPath="false"
        scopes="${componentName}" # space separated if multiple scopes need to be created/associated with the client
        enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
        ```

    !!! example

        [Kubernetes Dashboard](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/kubernetes-dashboard/post_install_scripts/deployOauth2.sh){:target="\_blank"}

        ```bash linenums="1" hl_lines="8"
        # Integrate solution with Keycloak
        redirectUris="https://${componentName}.${baseDomain}/login/generic_oauth"
        rootUrl="https://${componentName}.${baseDomain}"
        baseUrl="/login/generic_oauth"
        protocol="openid-connect"
        fullPath="true"
        scopes="groups" # space separated if multiple scopes need to be created/associated with the client
        enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
        ``` 

    !!! example

        [Grafana](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/monitoring/grafana/pre_install_scripts/configureOauthLogin.sh){:target="\_blank"}

        ```bash linenums="1" hl_lines="8"
        # Integrate solution with Keycloak
        redirectUris="https://${componentName}.${baseDomain}/login/generic_oauth"
        rootUrl="https://${componentName}.${baseDomain}"
        baseUrl="/login/generic_oauth"
        protocol="openid-connect"
        fullPath="true"
        scopes="groups" # space separated if multiple scopes need to be created/associated with the client
        enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
        ```

    !!! example

        [Mattermost](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/collaboration/mattermost/pre_install_scripts/createOidcConfig.sh){:target="\_blank"}

        ```bash linenums="1" hl_lines="8"
        # Integrate solution with Keycloak
        redirectUris="https://${componentName}.${baseDomain}/signup/gitlab/complete"
        rootUrl="https://${componentName}.${baseDomain}"
        baseUrl="/applications"
        protocol="openid-connect"
        fullPath="false"
        scopes="${componentName}" # space separated if multiple scopes need to be created/associated with the client
        enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
        ```

    Here also examples where it was not possible to use the `enableKeycloakSSOForSolution()` function, as some additional steps were necessary.

    [ArgoCD](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/cicd/argocd/post_install_scripts/deployOauth2.sh){:target="\_blank"}

    [Gitlab](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/cicd/gitlab/pre_install_scripts/createOAuth.sh){:target="\_blank"}



### createKeycloakClient()
:material-git: Location: [auto-setup/functions/keycloakCreateClient.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakCreateClient.sh){:target="\_blank"}

Creates a client in Keycloak for the component.

!!! note "Usage"
    `createKeycloakClient "<redirectUris>" "<rootUrl>" "<baseUrl>"`

!!! example
    ```bash linenums="1"
    # Create Keycloak Client
    redirectUris="https://${componentName}.${baseDomain}/users/auth/openid_connect/callback"
    rootUrl="https://${componentName}.${baseDomain}"
    baseUrl="/"
    export clientId=$(createKeycloakClient "${redirectUris}" "${rootUrl}" "${baseUrl}")
    ```

### createKeycloakClientScope()
:material-git: Location: [auto-setup/functions/keycloakCreateClientScope.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakCreateClientScope.sh){:target="\_blank"}

Creates a new client scope for a given client id in Keycloak. 

!!! note "Usage"
    `createKeycloakClientScope "<clientId>" "<protocol>" "<scope>"`

!!! example
    ```bash linenums="1"
    # Create Keycloak Client Scopes (if not already existing)
    protocol="openid-connect"
    scope="groups"
    export clientScopeId=$(createKeycloakClientScope "${clientId}" "${protocol}" "${scope}")
    ```

### createKeycloakGroup()
:material-git: Location: [auto-setup/functions/keycloakCreateGroup.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakCreateGroup.sh){:target="\_blank"}

Creates a new user group in Keycloak.

!!! note "Usage"
    `createKeycloakGroup "<group name>"`

!!! example
    ```bash linenums="1"
        # Create Keycloak Group (if not already existing)
        group="ArgoCDAdmins"
        export groupId=$(createKeycloakGroup "${group}")
    ```

### createKeycloakProtocolMapper()
:material-git: Location: [auto-setup/functions/keycloakCreateProtocolMapper.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakCreateProtocolMapper.sh){:target="\_blank"}

Creates a protocol mapper for a given client id

!!! note "Usage"
    `createKeycloakProtocolMapper "<clientId>" "<fullPath>"`

!!! example
    ```bash linenums="1"
    fullPath="false"
    createKeycloakProtocolMapper "${clientId}" "${fullPath}"
    ```

### createKeycloakUser()
:material-git: Location: [auto-setup/functions/keycloakCreateUser.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakCreateUser.sh){:target="\_blank"}

Create a new user in Keycloak.

!!! note "Usage"
    `createKeycloakUser "<username>"`

!!! example
    ```bash linenums="1"
    # Export Keycloak User Id (if not already existing)
    user="admin"
    export userId=$(createKeycloakUser "${user}")
    ```

### enableKeycloakSSOForSolution()
:material-git: Location: [auto-setup/functions/keycloakEnableSolution.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakEnableSolution.sh){:target="\_blank"}

!!! tip 
    This is usually the only Keycloak function you need to call when creating a new client in Keycloak, as this function, given all the inputs passed to it, takes care to call all the other needed functions.

!!! note "Usage"
    `enableKeycloakSSOForSolution "<redirectUris>" "<rootUrl>" "<baseUrl>" "<protocol>" "<fullPath>" "<scopes>"`

!!! example
    ```bash linenums="1"
    # Integrate solution with Keycloak
    redirectUris="https://${componentName}.${baseDomain}/login/generic_oauth"
    rootUrl="https://${componentName}.${baseDomain}"
    baseUrl="/login/generic_oauth"
    protocol="openid-connect"
    fullPath="true"
    scopes="groups" # space separated if multiple scopes need to be created/associated with the client
    enableKeycloakSSOForSolution "${redirectUris}" "${rootUrl}" "${baseUrl}" "${protocol}" "${fullPath}" "${scopes}"
    ```

### getKeycloakClientId()
:material-git: Location: [auto-setup/functions/keycloakGetClientId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakGetClientId.sh){:target="\_blank"}

Get the client id for a given client.

!!! note "Usage"
    `getKeycloakClientId "<client name>"`

!!! example
    ```bash linenums="1"
    # Get Keycloak Client Id
    export clientId=$(getKeycloakClientId "kubernetes")
    ```

### getKeycloakClientSecret()
:material-git: Location: [auto-setup/functions/keycloakGetClientSecret.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakGetClientSecret.sh){:target="\_blank"}

Get the client secret for a given client.

!!! note "Usage"
    `getKeycloakClientSecret "<clientId>"`

!!! example
    ```bash linenums="1"
    # Get Keycloak Client Secret
    export clientSecret=$(getKeycloakClientSecret "${clientId}")
    ```

### keycloakLogin()
:material-git: Location: [auto-setup/functions/keycloakLogin.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakLogin.sh){:target="\_blank"}

Login to Keycloak. This is required before launching any Keycloak CLI commands .

!!! info 
    This rarely needs to be called directly, as the other Keycloak functions already call this function before interacting with Keycloak.

!!! example
    ```bash linenums="1"
    # Call function to login to Keycloak
    keycloakLogin
    ```

### mapKeycloakUserToGroup()
:material-git: Location: [auto-setup/functions/keycloakMapUserToGroup.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakMapUserToGroup.sh){:target="\_blank"}

Maps a user in Keycloak to a Keycloak user group. Ensure the user is created beforehand if not already existing.

!!! note "Usage"
    `mapKeycloakUserToGroup "<userId>" "<groupId>"`

!!! example
    ```bash linenums="1"
    # Add user admin to the ArgoCDAdmins group. If any new users are created then they should be added to ArgoCDAdmins group
    groupMappingId=$(mapKeycloakUserToGroup "${userId}" "${groupId}")
    ```

### sourceKeycloakEnvironment()
:material-git: Location: [auto-setup/functions/keycloakSourceEnvironment.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/keycloakSourceEnvironment.sh){:target="\_blank"}

This function sets all the environment variables needed to successfully execute the Keycloak functions.
The environment variables set are the following:

| Variable name | Description |
| --- | --- |
| kcRealm | The Keycloak Realm, set to the full baseDomain (environment prefix + base domain). |
| kcInternalUrl | The Keycloak API URL for interacting with Keycloak from inside the Keycloak container. |
| kcAdmCli | The Keycloak CLI script to execute inside the Keycloak container. |
| kcPod | The name of the Kubernetes pod containing the Keycloak container |
| kcContainer | The name of the Keycloak container in the Keycloak pod |
| kcNamespace | The Keycloak Kubernetes namespace |

!!! note "Usage"
    sourceKeycloakEnvironment

!!! example
    ```bash linenums="1"
    # Source Keycloak Environment
    sourceKeycloakEnvironment
    ```

## Kubernetes

### kubernetesApplyYamlFile()
:material-git: Location: [auto-setup/functions/kubernetesApplyYamlFile.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/kubernetesApplyYamlFile.sh){:target="_blank"}

Executes the following actions against the YAML file path passed to it.
- Environment variable replacement for `{{ mustache_variables }}`
- Validation of YAML via [KubeVal](https://kubeval.instrumenta.dev/)
- kubectl apply of the YAML file to the specified namespace

If no namespace is provided, the resource will be applied to the `default` namespace - where relevant. Some resources do not live in a namespace, so for these, the namespace will be ignored.

!!! note "Usage"
    `kubernetesApplyYamlFile "<YAML file absolute path>" "<optional target kubernetes namespace>"`

!!! example
    ```bash linenums="1"
    kubernetesApplyYamlFile "${installationWorkspace}/kadalu-server-storage-pool-statefulset.yaml" "kadalu"
    ```

### kubernetesExportResource()
:material-git: Location: [auto-setup/functions/kubernetesExportResource.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/kubernetesExportResource.sh){:target="_blank"}

Does more than export a Kubernetes resource to a YAML file. It also strips it of the version specific items, to avoid issues during a `kubectl apply`.

The default process is as follows:

1. Export the resource as JSON
2. Use JSON processing to remove the kube management and version line items
3. Convert to YAML

If the selected output method is JSON (reason could be the need for additional JSON manipulation before converting to YAML), then the 3rd step will not be executed.

!!! note "Usage"
kubernetesExportResource "<resource name to export>" "<kubernetes resource type>" "<kubernetes namespace>" "<yaml or json>"
    ``

!!! example
    ```bash linenums="1"
    kubernetesExportResource "coredns" "configmap" "kube-system" "json"
    ```

### kubernetesHealthCheck()
:material-git: Location: [auto-setup/functions/kubernetesHealthCheck.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/kubernetesHealthCheck.sh){:target="_blank"}

Calls the Kubernetes health API. This is important for some procecesses that result in a temporary down-time of Kubernetes. This function lets the next steps know when Kubernetes is back online and healthy.

!!! note "Usage"
    `kubernetesHealthCheck`

!!! example
    ```bash linenums="1"
    kubernetesHealthCheck
    ```

### waitForKubernetesResource()
:material-git: Location: [auto-setup/functions/waitForKubernetesResource.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/waitForKubernetesResource.sh){:target="_blank"}

This checks and waits for a Kubernetes resource to become available. This is needed if a step, such as `kubernetesExportResource()` for example, needs a resource to be available before it can be successfully executed. 

!!! note "Usage"
    `waitForKubernetesResource "<resource name>" "<kubernetes resource type>" "<kubernetes namespace>"`

!!! example
    ```bash linenums="1"
    waitForKubernetesResource "server-storage-pool-1-0" "statefulset" "kadalu"
    ```

## Logging

### log_debug()
:material-git: Location: [auto-setup/functions/logDebug.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/logDebug.sh){:target="\_blank"}

Send message with timestamp and [DEBUG] prefix to KX.AS.CODE installation log.

!!! note "Usage"
    `log_debug "<log message>"`

### log_error()
:material-git: Location: [auto-setup/functions/logError.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/logError.sh){:target="\_blank"}

Send message with timestamp and [ERROR] prefix to KX.AS.CODE installation log.

!!! note "Usage"
    `log_error "<log message>"`

### log_info()
:material-git: Location: [auto-setup/functions/logInfo.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/logInfo.sh){:target="\_blank"}

Send message with timestamp and [INFO] prefix to KX.AS.CODE installation log.

!!! note "Usage"
    `log_info "<log message>"`

### log_warn()
:material-git: Location: [auto-setup/functions/logWarn.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/logWarn.sh){:target="\_blank"}

Send message with timestamp and [WARN] prefix to KX.AS.CODE installation log.

!!! note "Usage"
    `log_warn "<log message>"`

## Mattermost

### mattermostCreateChannel()
:material-git: Location: [auto-setup/functions/mattermostCreateChannel.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostCreateChannel.sh){:target="_blank"}

Create a Mattermost channel.

!!! note "Usage"
    `mattermostCreateChannel "<channel name>" "<team id>"`

!!! example
    ```bash linenums="1"
    # Get Mattermost team id
    kxascodeTeamId=$(mattermostGetTeamId "kxascode")
    # Add Channels
    mattermostCreateChannel "Security" "${kxascodeTeamId}"
    ```

### mattermostCreateTeam()
:material-git: Location: [auto-setup/functions/mattermostCreateTeam.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostCreateTeam.sh){:target="_blank"}

Create a Mattermost team.

!!! note "Usage"
    `mattermostCreateTeam "<team name>" "<team headline>"`

!!! example
    ```bash linenums="1"
    mattermostCreateTeam "kxascode" "Team KX.AS.CODE"
    ```

### mattermostCreateUser()
:material-git: Location: [auto-setup/functions/mattermostCreateUser.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostCreateUser.sh){:target="_blank"}

Create a Mattermost user.

!!! note "Usage"
    `mattermostCreateUser "<username>"`

!!! example
    ```bash linenums="1"
    # Create technical user for posting notifications
    mattermostCreateUser "security"
    ```

### mattermostCreateWebhook()
:material-git: Location: [auto-setup/functions/mattermostCreateWebhook.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostCreateWebhook.sh){:target="_blank"}

Create a Mattermost webhook.

!!! note "Usage"
    `mattermostCreateWebhook "<mattermost webhook name>" "<mattermost team name>" "<mattermost channel name>" "<mattermost webhook avatar url>"`

!!! example
    ```bash linenums="1"
    mattermostCreateWebhook "cicd" "kxascode" "CICD" "https://about.gitlab.com/images/press/logo/png/gitlab-logo-500.png"
    ```

### mattermostGetChannelId()
:material-git: Location: [auto-setup/functions/mattermostGetChannelId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostGetChannelId.sh){:target="_blank"}

Get a Mattermost channel id.

!!! note "Usage"
    `mattermostGetChannelId "<mattermost team name>" "<mattermost channel name>"`

!!! example
    ```bash linenums="1"
    channelId=$(mattermostGetChannelId "kxascode" "Security")
    ```

### mattermostGetLoginToken()
:material-git: Location: [auto-setup/functions/mattermostGetLoginToken.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostGetLoginToken.sh){:target="_blank"}

This is normally called automatically before performing any of the other Mattermost calls. It gets the login token needed to authorize next steps.

!!! note "Usage"
    `mattermostGetLoginToken "<usernmame>"`

!!! example
    ```bash linenums="1"
    mattermostLoginToken=$(mattermostGetLoginToken "admin")
    ```

### mattermostGetTeamId()
:material-git: Location: [auto-setup/functions/mattermostGetTeamId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostGetTeamId.sh){:target="_blank"}

Get a Mattermost team id.

!!! note "Usage"
    `mattermostGetTeamId "<mattermost team name>"`

!!! example
    ```bash linenums="1"
    # Get Mattermost team id
    kxascodeTeamId=$(mattermostGetTeamId "kxascode")
    ```

### mattermostGetUserId()
:material-git: Location: [auto-setup/functions/mattermostGetUserId.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostGetUserId.sh){:target="_blank"}

Get a Mattermost user id.

!!! note "Usage"
    `mattermostGetUserId "<mattermost username>"`

!!! example
    ```bash linenums="1"
    # Get Mattermost User Id
    mattermostUserId=$(mattermostGetUserId "${mattermostUsername}")
    ```

### mattermostMapUserToTeam()
:material-git: Location: [auto-setup/functions/mattermostMapUserToTeam.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/mattermostMapUserToTeam.sh){:target="_blank"}

Map a Mattermost user to a Mattermost Team.

!!! note "Usage"
    `mattermostMapUserToTeam "<mattermost username>" "<mattermost team name>"`

!!! example
    ```bash linenums="1"
    mattermostMapUserToTeam "securty" "kxascode"
    ```

## MinIO-S3

### minioS3CreateBucket()
:material-git: Location: [auto-setup/functions/minioS3CreateBucket.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/minioS3CreateBucket.sh){:target="_blank"}

Create bucket in MinIO-S3.

!!! note "Usage"
    `minioS3CreateBucket "<bucket name>" "<minio tenant>" "<aws compatible region>"`

!!! example
    ```bash linenums="1"
    minioS3CreateBucket "mattermost-file-storage" "mattermost" "eu-central-1"
    ```

### minioS3CreateServiceAccount()
:material-git: Location: [auto-setup/functions/minioS3CreateServiceAccount.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/minioS3CreateServiceAccount.sh){:target="_blank"}

Create MinIO service account. TRhe generated service account's api key and secret will be published to GoPass.

!!! note "Usage"
    `minioS3CreateServiceAccount "<minio service account name>"`

!!! example
    ```bash linenums="1"
    minioS3CreateServiceAccount "kxascode-sa"
    ```

### minioS3CreateTenant()
:material-git: Location: [auto-setup/functions/minioS3CreateTenant.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/minioS3CreateTenant.sh){:target="_blank"}

Creates a new tenant in [MinIO](https://docs.min.io/minio/k8s/tenant-management/deploy-minio-tenant.html){:target="\_blank"}. See here for more information on MinIO tenants.

!!! note "Usage"
    `minioS3CreateTenant "<tenant name>"`

!!! example
    ```bash linenums="1"
    minioS3CreateTenant "gitlab"
    ```

### minioS3GetAccessAndSecretKeys()
:material-git: Location: [auto-setup/functions/minioS3GetAccessAndSecretKeys.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/minioS3GetAccessAndSecretKeys.sh){:target="_blank"}

Sets two global variables, `minioAccessKey` and `minioSecretKey`, that can be used in subsequent steps.

!!! note "Usage"
    `minioS3GetAccessAndSecretKeys <service account name>`

!!! example
    ```bash linenums="1"
    minioS3GetAccessAndSecretKeys "gitlab"
    ```

### minioS3Initialize()
:material-git: Location: [auto-setup/functions/minioS3Initialize.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/minioS3Initialize.sh){:target="_blank"}

Basic steps to allow the MinIO instance to be manageable via MinIO's command line tool - `mc`.

!!! note "Usage"
    `minioS3Initialize`

!!! example
    ```bash linenums="1"
    minioS3Initialize
    ```

## Notifications
### addToNotificationQueue()
:material-git: Location: [auto-setup/functions/addToNotificationQueue.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/addToNotificationQueue.sh){:target="\_blank"}

Adds a notification to the RabbitMQ `notification_queue`.

!!! info
This is called by `notifyAllChannels` and most likely no need to call it on its own.

### notify()
:material-git: Location: [auto-setup/functions/notify.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/notify.sh){:target="\_blank"}

Sends a notification to the desktop. It receives the `message` as input, as well `dialogue_type`, which can be either `info` (shows as blue), `warn` (orange) or `error` (red).

!!! note "Usage"
`notify "<message>" "<dialog_type>"`

Send a notification to the Linux desktop only. Preferred method is to send a notification to all channels, which results in the notification also being displayed in the KX-Portal NodeJS webapp.
See function, _notifyAllChannels_.

### notifyAllChannels()
:material-git: Location: [auto-setup/functions/notifyAllChannels.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/notifyAllChannels.sh){:target="\_blank"}

Send a notification to both the Linux desktop and to the KX-Portal via the RabbitMQ "notification_queue".

!!! note "Usage"
`notifyAllChannels "<message>" "<log_level>" "<action_status>"`

| Field Name | Description | Possible Values | 
| ---------------|----------------|----------------|
| message | The alert text that should be displayed on the desktop or in the KX-Portal | Free-form text. No restriction. |
| log_level | The type of notification dialogue to show | info (shows as blue), warn (orange) or error (red) |
| status | This should be the status of the last action, eg. install | success, failure |


## RabbitMQ Core Setup

These are part of the core setup and should never need to be called separately by any of the component installation routines.

### checkRabbitMq()
:material-git: Location: [auto-setup/functions/rabbitMQCheck.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/rabbitMQCheck.sh){:target="\_blank"}

Checks if `rabbitmqadmin` is installed. If not, installed it, including setting up bash completion scripts.

!!! note "Usage"
`checkRabbitMq`

### createRabbitMQExchange()
:material-git: Location: [auto-setup/functions/rabbitMQExchangeCreation.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/rabbitMQExchangeCreation.sh){:target="\_blank"}

Creates the rabbitMQ exchange if not already present.

!!! note "Usage"
`createRabbitMQExchange`

### createRabbitMQQueues()
:material-git: Location: [auto-setup/functions/rabbitMQQueuesCreation.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/rabbitMQQueuesCreation.sh){:target="\_blank"}

Creates the rabbitMQ queues if not already present.

!!! note "Usage"
`createRabbitMQQueues`

### createRabbitMQWorkflowBindings()
:material-git: Location: [auto-setup/functions/rabbitMQWorkflowBindingsCreation.sh](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/functions/rabbitMQWorkflowBindingsCreation.sh){:target="\_blank"}

Creates the rabbitMQ workflow bindings if not already present.

!!! note "Usage"
`createRabbitMQWorkflowBindings`

