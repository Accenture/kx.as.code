# Testing

To ensure that the platform works across all the supported virtualization platforms, the following setup is tested regularly.

|Virtualization|Host Operating System|Startup Mode|Orchestrator|Installation Groups|
|----|----|----|----|----|
|Parallels|MacOS Monterey|Minimal|K3s|CICD Group 3, Monitoring Group 3, Security Group 2|
|VirtualBox|Windows 11|Normal|K8s|CICD Group 1, Security Group 2, QA Group, Monitoring Group 1|
|VMWare Workstation|Debian Linux 11|Lite|K8s|Monitoring Group 1, CICD Group 2, Cloud Storage Group|

The matrix above ensures we hit as many combinations as possible.

The private and public clouds are not tested as often due to environment limitations. OpenStack is tested the most out of the clouds, and AWS the least frequently. 

If you are developing to add solutions to KX.AS.CODE, consider to test the following:

- `Repeatability` - a script mut be able to run twice without error, which requires validations, so that if for example, an API call already succeeded in the previous run, then it is not executed again, preventing "x already exists" error messages, and the item going unnecessarily into the failure queue.
  
- `Transparency` - A script must exit with RC1 if any step does not succeed - this ensures that the user get the correct notification and transparency, whether the installation succeeded or not. Additionally, the framework retries 3 times or sends it to the failure queue for further analysis, if the maximum number of retries is reached.
