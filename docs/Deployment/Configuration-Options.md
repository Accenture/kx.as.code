# Profile Configuration

Each [deployment profile](./Deployment-Profiles.md) needs a profile-config.json file to describe how it should start up, and once the VMs are up, how things such as networking and storage should be configured.

All of this is described in the profile-config.json. Here an example file.

```json
    {
        "config": {
            "allowWorkloadsOnMaster": "true",
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
            "kubeOrchestrator": "k8s",
            "local_volumes": {
                "fifty_gb": 0,
                "five_gb": 10,
                "one_gb": 10,
                "ten_gb": 10,
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
            "selectedTemplates": "null",
            "sslProvider": "self-signed",
            "standaloneMode": "false",
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
            "updateSourceOnStart": "true",
            "virtualizationType": "local",
            "vm_properties": {
                "3d_acceleration": "off",
                "main_admin_node_cpu_cores": 4,
                "main_admin_node_memory": 12288,
                "main_node_count": 1,
                "main_replica_node_cpu_cores": 2,
                "main_replica_node_memory": 8196,
                "worker_node_count": 2,
                "worker_node_cpu_cores": 6,
                "worker_node_memory": 32768
            }
        }
    }
```

Each item in example JSON file above is described in more detail in the table below.

Where a configuration item is marked as not "Configurable via Launcher", the setting must be completed directly in profile-config.json. For all others, see the Quick Start Guide on how to adjust the configuration in the [Jenkins based configurator and launcher](../Quick-Start-Guide.md).

| Property                                                            | Description                                                                                                                                                                                                                  | Configurable via Launcher? | Default Value            |
|---------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------|--------------------------|
| config.allowWorkloadsOnMaster                                       | If false, taints will be removed from Kubernetes Kx-Main nodes, to allow pod scheduling on them                                                                                                                              | Yes                        | `true`                   |
| config.baseDomain                                                   | Configure wildcard domain that will be used to access all the applications                                                                                                                                                   | Yes                        | `demo1.kx-as-code.local` |
| config.baseIpType                                                   | This must be set to `dynamic` or `static`                                                                                                                                                                                    | No                         | -                        |
| config.basePassword                                                 | The password of the initial user                                                                                                                                                                                             | Yes                        | `L3arnandshare`          |
| config.baseUser                                                     | The initial user for accessing the desktop, all applications and SSH                                                                                                                                                         | Yes                        | `kx.hero`                |
| config.certificationMode                                            | [deprecated]                                                                                                                                                                                                                 | -                          | -                        |
| config.defaultKeyboardLanguage                                      | The default language KX.AS.CODE has enabled initially. The language is adjustable onthe desktop via the tray icon                                                                                                            | No                         | `de`                     |
| config.disableLinuxDesktop                                          | Disables the Linux desktop completely and boot the main node to a compand prompt. There is a script in /usr/share/kx.as.code/workspace to re-enable it                                                                       | Yes                        | `false`                  |
| config.disableSessionTimeout                                        | Disables the timeout in the Kubernetes Dashboard                                                                                                                                                                             | No                         | `true`                   |
| config.dnsResolution                                                | ----                                                                                                                                                                                                                         | No                         | `hybrid`                 |
| config.docker<br/>.dockerhub_email                                  | Dockerhub login email. Only needed if exceeding the download rate limit                                                                                                                                                      | No                         | -                        |
| config.docker<br/>.dockerhub_password                               | Dockehub password. Only needed if exceeding the download rate limit                                                                                                                                                          | No                         | -                        |
| config.docker<br/>.dockerhub_username                               | Dockerhub username. Only needed if exceeding the download rate limit                                                                                                                                                         | No                         | -                        |
| config.environmentPrefix                                            | The FQDN baseDomain is made  up of two parts. The `config.baseDomain` above and `config.environmentPrefix`                                                                                                                   | Yes                        | `demo1`                  |
| config.glusterFsDiskSize                                            | The size of the network storage to be thinly provisioned. Vagrant will take care to create and mount the drive which will be used by GlusterFS. This is not used in the minimal start mode.                                  | Yes                        | `200GB`                  |
| config.kubeOrchestrator                                             | `k3s` or `k8s`                                                                                                                                                                                                               | Yes                        | `k3s`                    |
| config.local_volumes.fifty_gb                                       | Number of local 50GB volumes to (thinly) provision on each node                                                                                                                                                              | Yes                        | `0`                      |
| config.local_volumes.five_gb                                        | Number of local 5GB volumes to (thinly) provision on each node                                                                                                                                                               | Yes                        | `10`                     |
| config.local_volumes.one_gb                                         | Number of local 1GB volumes to (thinly) provision on each node                                                                                                                                                               | Yes                        | `10`                     |
| config.local_volumes.ten_gb                                         | Number of local 10GB volumes to (thinly) provision on each node                                                                                                                                                              | Yes                        | `10`                     |
| config.local_volumes.thirty_gb                                      | Number of local 30GB volumes to (thinly) provision on each node                                                                                                                                                              | Yes                        | `0`                      |
| config.metalLbIpRange<br/>.ipRangeEnd                               | The end range for the MetalLB load-balancer. In most cases the default should be OK                                                                                                                                          | No                         | `10.10.76.150`           |
| config.metalLbIpRange<br/>.ipRangeStart                             | The start range for the MetalLB load-balancer. In most cases the default should be OK                                                                                                                                        | No                         | `10.10.76.100`           |
| config.proxy_settings<br/>.http_proxy                               | The http proxy URL. May be needed in some corporate situations                                                                                                                                                               | No                         | -                        |
| config.proxy_settings<br/>.https_proxy                              | The https proxy URL. May be needed in some corporate situations                                                                                                                                                              | No                         | -                        |
| config.proxy_settings<br/>.no_proxy                                 | URLs/IPs the proxy setting should ignore. May be needed in some corporate situations                                                                                                                                         | No                         | -                        |
| config.selectedTemplates                                            | Relevant for the Jenkins based configurator only. A list of templates last selected in the Jenkins configurator                                                                                                              | No                         | -                        |
| config.sslProvider                                                  | Can be self-signed or letsencrypt. Self-signed used the locally provisioned CFSSL based CALetsencrypt mainly makes sense in a cloud setting, where there is a route back to the service the certificate is being created for | No                         | `self-signed`            |
| config.standaloneMode                                               | May be deprecated soon, but determines if the set is running in a one-node (eg. just one kx-main node), which drives decisions later whether to install network storage or not                                               | Yes                        | `true`                   |
| config.startupMode                                                  | normal, lite, or minimal. See the Quick Start Guide to see what is included in each mode                                                                                                                                     | Yes                        | `normal`                 |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-main1   | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.200`           |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-main2   | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.201`           |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-main3   | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.202`           |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-worker1 | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.203`           |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-worker2 | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.204`           |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-worker3 | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.205`           |
| config.staticNetworkSetup<br/>.baseFixedIpAddresses<br/>.kx-worker4 | Only has an effect if `baseIpType` is set to `static`. Sets the IP for the given node                                                                                                                                        | No                         | `10.10076.206`           |
| config.staticNetworkSetup<br/>.dns1                                 | Only has an effect if `baseIpType` is set to `static`.                                                                                                                                                                       | No                         | `10.10076.200`           |
| config.staticNetworkSetup<br/>.dns2                                 | Only has an effect if `baseIpType` is set to `static`.                                                                                                                                                                       | No                         | `8.8.8.8`                |
| config.staticNetworkSetup<br/>.gateway                              | Only has an effect if `baseIpType` is set to `static`.                                                                                                                                                                       | No                         | `10.10076.1`             |
| config.updateSourceOnStart                                          | Determines whether the latest KX.AS.CODE source should be pulled from GitHub when the environment first initializes                                                                                                          | No                         | `true`                   |
| config.virtualizationType                                           | `local_virtualization`, `private_cloud` or `public_cloud`                                                                                                                                                                    | No                         | -                        |
| config.vm_properties<br/>.3d_acceleration                           | VirtualBox specific. Turning it off solved some display issues                                                                                                                                                               | No                         | `true`                   |
| config.vm_properties<br/>.main_admin_node_cpu_cores                 | Number of CPU cores to allocate to KX-Main1 node. The node that contains the Kubernetes control-plane, and the desktop, plus all the admin tools, as well as network storage daemon etc                                      | Yes                        | `true`                   |
| config.vm_properties<br/>.main_admin_node_memory                    | Memory size in MBs to allocate to KX-Main1 node                                                                                                                                                                              | Yes                        | `true`                   |
| config.vm_properties<br/>.main_node_count                           | Number of Kx-Main nodes to start                                                                                                                                                                                             | Yes                        | `true`                   |
| config.vm_properties<br/>.main_replica_node_cpu_cores               | Number of CPU cores to allocate to KX-Main* nodes (control-plane without the desktop and admin tools on Kx-Main1)                                                                                                            | Yes                        | `true`                   |
| config.vm_properties<br/>.main_replica_node_memory                  | Memory size in MBs to allocate to KX-Main* nodes                                                                                                                                                                             | Yes                        | `true`                   |
| config.vm_properties<br/>.worker_node_count                         | Number of Kx-Worker nodes to start                                                                                                                                                                                           | Yes                        | `true`                   |
| config.vm_properties<br/>.worker_node_cpu_cores                     | Number of CPU cores to allocate to KX-Worker nodes                                                                                                                                                                           | Yes                        | `true`                   |
| config.vm_properties<br/>.worker_node_memory                        | Memory size in MBs to allocate to KX-Worker nodes                                                                                                                                                                            | Yes                        | `true`                   |
