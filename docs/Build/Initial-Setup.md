# Jenkins Setup Guide

## Preinstall Steps

Prepare prerequisites according to [Build Environment](./Build-Environment.md).

For MacOS, install latest screen by executing the following command. Using the default MacOSX "screen" tool will result in an error.
```
brew install screen
```
## Configure Jenkins.env
1. Copy `base-vm/build/jenkins/jenkins.env_template` as `base-vm/build/jenkins/jenkins.env`.
2. Fill Github username and Personal Access Token (optional. not needed if using public repository)
    ```
    git_source_username = "your_github_username"
    git_source_password = "your_github_pat"
    ```
## Run launchLocalBuildEnvironment.sh
```
cd base-vm/build/jenkins
# For Linux or MacOS
./launchLocalBuildEnvironment.sh
# For Windows PowerShell
.\launchLocalBuildEnvironment.ps1
```
Wait until the build is finished.

If the following message is shown,
```
- [WARN] One or more OPTIONAL components required to successfully build packer images for KX.AS.CODE for VMWARE were missing. Ignore if not building VMware images
Do you wish to continue anyway?
1) Yes
2) No
```
Enter 1 to continue.

In the end, this message will be shown in console

<span style="color:green">- [INFO] Congratulations! Jenkins for KX.AS.CODE is successfully configured and running. Access Jenkins via the following URL: http://127.0.0.1:8080</span>

which means the build was successful.

## Initialise Virtual Machine KX.AS.CODE
1. Access Jenkins via http://127.0.0.1:8080
2. Go to  `KX.AS.CODE_Launcher` -> `Build with Parameters`
3. Select the profile to create VM
4. Click "Start Build" icon on `Build VM images` -> KX.AS.CODE.MAIN
5. Refresh status by clicking "Refresh Data" icon.
When the build is finished, build status will become <span style="color:green">Success</span>.

## Configure
Navigate to other tabs and allocate appropriate resources for KX.AS.CODE.

## Review and Launch
Navigate to the last tab `Review and Launch`, click `Start Environment` to build the enviroment in the main node.
When the build is finished, status will become <span style="color:green">Success</span>.
