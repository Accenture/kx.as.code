# Jenkins Builder & Launcher

## Pre-install Steps

Prepare prerequisites according to the [Build Environment](./Build-Environment.md) guide.

For MacOS, install latest screen by executing the following command. Using the default MacOSX "screen" tool will result in an error.
```bash
brew install screen
```

## Configure Jenkins.env
1. Copy `base-vm/build/jenkins/jenkins.env_template` as `base-vm/build/jenkins/jenkins.env`.
2. Fill Github username and Personal Access Token (optional. not needed if using public repository)
    ```bash
    git_source_username = "your_github_username"
    git_source_password = "your_github_pat"
    ```
   
## Run launchLocalBuildEnvironment.sh
```bash
cd base-vm/build/jenkins
# For Linux or MacOS
./launchLocalBuildEnvironment.sh
# For Windows PowerShell
.\launchLocalBuildEnvironment.ps1
```
Wait until the build is finished.

If the following message is shown,
```bash
- [WARN] One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images
Do you wish to continue anyway?
1) Yes
2) No
```
If you do not intend to build VMWare images, `1` to continue anyway.

In the end, this message will be shown in console

```bash
- [INFO] Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: http://localhost:8080/job/KX.AS.CODE_Launcher/build?delay=0sec
```

If you get the `Congratulations`, Jenkins is up and running, you can access it via the URL [http://localhost:8081/job/KX.AS.CODE_Launcher/build?delay=0sec](http://localhost:8080/job/KX.AS.CODE_Launcher/build?delay=0sec){:target="\_blank"}.

!!! warning "Remember that if you changed the IP or port for Jenkins in `jenkins.env`, you will need to use that when launching the Jenkins URL, instead of the default `localhost:8080` combination."

