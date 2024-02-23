# Initialize Launcher

## Pre-install Steps

Prepare prerequisites according to the [Build Environment](../Build/Local-Virtualizations.md) guide.

!!! danger "MacOSX launchLocalBuildEnvironment.sh incompatibilities"
    MacOSX contains old packages for `screen` and `openssl`, compared to Linux and Windows. Please upgrade these packages. The easiest way to do this is with [Homebrew](https://brew.sh/){:target="\_blank"}.
    ```
    # Upgrade incompatible packages on MacOSX before launching launchLocalBuildEnvironment.sh!
    brew install openssl screen
    ```

## Configure Jenkins.env

1. Copy `base-vm/build/jenkins/jenkins.env_template` to `base-vm/build/jenkins/jenkins.env`.
2. At the minimal, ensure the yellow highlighted lines match your environment

      ```bash linenums="1" hl_lines="3 4 5 6 7"
      # General Jenkins Variables. Minimal required. Enough for local virtualization
      # JNLP secret must be left blank for default agent that is installed with the initial setup
      jenkins_listen_address = "127.0.0.1"  ## Set to localhost for security reasons
      # !!! IMPORTANT - Ensure for Mac/Linux you set the paths for "jenkins_home" and "jenkins_shared_workspace" to start with ./ instead of .\ for Windows!
      jenkins_server_port = "8081"
      jenkins_home = ".\jenkins_home"
      jenkins_shared_workspace = ".\shared_workspace"
   
      # General Packer Build Variables
      # git_source_branch and/or git_repo_url must be updated if you created a new branch or forked the original repository
      kx_vm_user = "kx.hero"
      kx_vm_password = "L3arnandshare"
      git_source_url = "https://github.com/Accenture/kx.as.code.git"
      git_source_branch = "main"
      kx_main_hostname = "kx-main"
      kx_node_hostname = "kx-node"
      kx_domain = "kx-as-code.local"
   
      # Variables for Automated Secret Generation
      git_source_username = ""  # not needed for public repository
      git_source_password = ""  # not needed for public repository
      dockerhub_username = ""  # only needed if you have reached your download limit
      dockerhub_password = ""  # only needed if you have reached your download limit
      dockerhub_email = ""  # only needed if you have reached your download limit
      ```

## Run launchLocalBuildEnvironment

Depending on whether you are running on MacOSX, Linux or Windows, you will need to execute the following launcher script from the repository root.

```bash
cd base-vm/build/jenkins
# For Linux or MacOSX
./startLauncher.sh

# For Windows PowerShell
.\startLauncher.ps1
```

The script takes care of:

- Downloading the Jenkins WAR file
- Downloading all necessary tools (including Java, jq, packer, mo)
- Applying KX.AS.CODE customizations to Jenkins
- Generating the Jenkins jobs
- Creating password credential in Jenkins

!!! note
    Vagrant still needs to be installed manually, as it is not a portable installer/utility. You can download Vagrant from [here](https://www.vagrantup.com/downloads.html){:target="\_blank"}

If the following message is shown,

<pre>
<code><span style="white-space: pre-wrap;">[WARN] One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images
Do you wish to continue anyway?
1) Yes
2) No</span>
</code>
</pre>

Select `1` if you do not intend to build VMWare images. You can download the needed [OVFTool](https://code.vmware.com/web/tool/4.4.0/ovf){:target="\_blank"} later manually if you change your mind.

If all goes well, you should see the following message in the console:

!!! success
    - [INFO] Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: [http://localhost:8080/job/KX.AS.CODE_Launcher/build?delay=0sec](http://localhost:8080/job/KX.AS.CODE_Launcher/build?delay=0sec){:target="\_blank"}."

!!! warning
    If you changed the IP or port for Jenkins in `jenkins.env`, you will need to use that when launching the Jenkins URL, instead of the default `localhost:8080` combination."
