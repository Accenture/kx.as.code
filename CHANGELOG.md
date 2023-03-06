# Changelog

## [v0.8.13](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.13) (2023-03-05)
v0.8.13 is a bumper release with quite a few new features and bug fixes. 
Read the full list below for details.

**Implemented enhancements:**

- Improve validations on launcher script [\#436](https://github.com/Accenture/kx.as.code/issues/436)
- Use DockerHub login if provided to increase rate-limit [\#435](https://github.com/Accenture/kx.as.code/issues/435)
- Ensure K3s respects no-workloads-on-master setting [\#430](https://github.com/Accenture/kx.as.code/issues/430)
- Update Debian Linux to 11.5 [\#428](https://github.com/Accenture/kx.as.code/issues/428)
- Add more keyboard languages \(us,de,it,in,gb,fr,es,cn\) [\#424](https://github.com/Accenture/kx.as.code/issues/424)
- Ensure all logged in desktop users receive notifications [\#422](https://github.com/Accenture/kx.as.code/issues/422)
- Upgrade Remote Desktop applications [\#421](https://github.com/Accenture/kx.as.code/issues/421)
- Create common wrapper function for all script executions [\#412](https://github.com/Accenture/kx.as.code/issues/412)
- Add function to remove control characters from bash variables [\#406](https://github.com/Accenture/kx.as.code/issues/406)
- Remove line numbering in VIM [\#398](https://github.com/Accenture/kx.as.code/issues/398)
- Add central function to search for and download Maven artifacts [\#397](https://github.com/Accenture/kx.as.code/issues/397)
- Enable framework update from Git on start also with credentials [\#395](https://github.com/Accenture/kx.as.code/issues/395)
- Add Lynx for improved readability of API call HTML responses [\#394](https://github.com/Accenture/kx.as.code/issues/394)
- Add script execution duration for statistical purposes and debugging [\#393](https://github.com/Accenture/kx.as.code/issues/393)
- Add function to import custom Grafana dashboards via JSON file [\#390](https://github.com/Accenture/kx.as.code/issues/390)
- Add Prometheus-Stack operator component [\#389](https://github.com/Accenture/kx.as.code/issues/389)
- Allow namespace in Kubernetes YAML files to override component default [\#388](https://github.com/Accenture/kx.as.code/issues/388)
- Add JProfiler for JVM profiling [\#387](https://github.com/Accenture/kx.as.code/issues/387)
- Enable AWS EC2 management agent [\#386](https://github.com/Accenture/kx.as.code/issues/386)
- Create central function for command execution and associated error handling [\#385](https://github.com/Accenture/kx.as.code/issues/385)
- Enable installation to resume where it left off after script failure [\#384](https://github.com/Accenture/kx.as.code/issues/384)
- Enable notifications to Slack, E-Mail and Microsoft Teams [\#383](https://github.com/Accenture/kx.as.code/issues/383)

**Fixed bugs:**

- Cannot install K8s as apt-key no longer valid [\#432](https://github.com/Accenture/kx.as.code/issues/432)
- Harbor install fails when Keycloak not installed [\#420](https://github.com/Accenture/kx.as.code/issues/420)
- Secret salt file not generated on Windows [\#417](https://github.com/Accenture/kx.as.code/issues/417)
- Launched from portal tasks don't execute [\#415](https://github.com/Accenture/kx.as.code/issues/415)
- Helm persistence setting is breaking Grafana install [\#413](https://github.com/Accenture/kx.as.code/issues/413)
- Grafana desktop icon missing for Prometheus-Stack [\#411](https://github.com/Accenture/kx.as.code/issues/411)
- Grafana-Loki datasource and dashboard not imported into new Prometheus-Stack [\#410](https://github.com/Accenture/kx.as.code/issues/410)
- Graphite Helm install fails due to invalid ingress apiVersion [\#409](https://github.com/Accenture/kx.as.code/issues/409)
- Web health check fails if not all optional parameters passed [\#407](https://github.com/Accenture/kx.as.code/issues/407)
- Framework update fails as repository directory deemed not safe [\#405](https://github.com/Accenture/kx.as.code/issues/405)
- External DNS resolution not working inside Kubernetes pods [\#404](https://github.com/Accenture/kx.as.code/issues/404)
- SKEL directory not consistent across all scripts [\#403](https://github.com/Accenture/kx.as.code/issues/403)
- Retry for KX-Portal install is not working correctly [\#402](https://github.com/Accenture/kx.as.code/issues/402)
- Function downloadFile\(\) retry mechanism not working correctly [\#401](https://github.com/Accenture/kx.as.code/issues/401)
- checkUrlHealth\(\) fails if not all optional parameters passed [\#400](https://github.com/Accenture/kx.as.code/issues/400)
- KDE windows on desktop unmovable in NoMachine Remote Desktop [\#399](https://github.com/Accenture/kx.as.code/issues/399)
- VSCode desktop shortcut icon no longer shows [\#396](https://github.com/Accenture/kx.as.code/issues/396)
- Kubernetes YAML file validation fails for custom resources [\#392](https://github.com/Accenture/kx.as.code/issues/392)
- Running pods check not correct when "Evicted" pods present [\#391](https://github.com/Accenture/kx.as.code/issues/391)

# History

History is the past, the future is [here](https://accenture.github.io/kx.as.code/Overview/Future-Roadmap/)

## [v0.8.12](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.12) (2022-09-18)
This release contains a critical fix! The fix resolved an issue where the Linux NetworkManager and Kubernetes were getting in each others way, resulting in unstable workloads. The rest of the changes are mainly minor enhancements and fixes. See full release note below.

**Implemented enhancements:**

- Upgrade OpenLens to v6.1.13 #369
- Enable NoMachine for ARM64 CPU architecture #368
- Widen global variables tab table spacing #352
- Enhance experience meter in Jenkins based launcher #351
- Update Documentation #350

**Fixed bugs:**

- External access directory not created for cloud instance #370
- Fix new user initialisation #367
- Remove repetitive warning when using sudo #366
- Deployed services in Kubernetes are not stable #365
- Remembering Orchestrator and Start-Mode not working on Mac and Linux #348
- KX-Portal backend server crashing with TypeError: Cannot read properties of null (reading 'message') #336

## [v0.8.11](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.11) (2022-09-18)
v0.8.11 is a bumper release with quite a few new features and bug fixes. A major new feature is the ability to execute "tasks" against a "component" once it has been installed (for example, "purge deleted images" in the "docker-registry" component). Tasks are defined in the component's metadata,json.  The client KX-Portal also received a number of updates, including the ability to launch the new tasks.
Read the full list below for more details.

**Implemented enhancements:**

- Remember startup-mode and orchestrator settings in Jenkins launcher [\#337](https://github.com/Accenture/kx.as.code/issues/337)
- Replace Typora with OpenSource alternative [\#335](https://github.com/Accenture/kx.as.code/issues/335)
- Add more dev tools, such as IntelliJ and Azure Data Studio [\#331](https://github.com/Accenture/kx.as.code/issues/331)
- Make it visible on application cards when an app has available tasks [\#329](https://github.com/Accenture/kx.as.code/issues/329)
- Allow variable substitutions for metadata.json environment variables [\#328](https://github.com/Accenture/kx.as.code/issues/328)
- Get version number dynamically from versions.json [\#326](https://github.com/Accenture/kx.as.code/issues/326)
- Add logLevel option to profile settings [\#322](https://github.com/Accenture/kx.as.code/issues/322)
- Add individually executable "tasks" after solution deployed [\#320](https://github.com/Accenture/kx.as.code/issues/320)
- Allow custom variables to be passed to VM via profile [\#318](https://github.com/Accenture/kx.as.code/issues/318)
- Add authentication option to downloadFile function [\#315](https://github.com/Accenture/kx.as.code/issues/315)
- Improve security for transferring credentials into VM [\#314](https://github.com/Accenture/kx.as.code/issues/314)
- Jenkins launcher to accept repo names other than kx.as.code [\#312](https://github.com/Accenture/kx.as.code/issues/312)
- Allow override of central functions with custom ones [\#302](https://github.com/Accenture/kx.as.code/issues/302)
- Add ability to customize background & logo [\#301](https://github.com/Accenture/kx.as.code/issues/301)
- Add basic UI frontend to core Docker-Registry component [\#300](https://github.com/Accenture/kx.as.code/issues/300)
- Application components not consistent when description text not all of same length [\#279](https://github.com/Accenture/kx.as.code/issues/279)
- Hide core components in GUI unless selected [\#278](https://github.com/Accenture/kx.as.code/issues/278)

**Fixed bugs:**

- Messages not ending up on notification\_queue [\#323](https://github.com/Accenture/kx.as.code/issues/323)
- Cannot delete docker images from registry via UI [\#321](https://github.com/Accenture/kx.as.code/issues/321)
- Git checkout not working if user is email address [\#311](https://github.com/Accenture/kx.as.code/issues/311)
- KX.AS.CODE auto-update source on first start not working [\#306](https://github.com/Accenture/kx.as.code/issues/306)
- Blank screen in KX-Portal from page 4 onwards [\#280](https://github.com/Accenture/kx.as.code/issues/280)

## [v0.8.10](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.10) (2022-08-16)
This is a fairly minor release and has been mainly about stabilization and finalizing the documentation.

**Implemented enhancements:**

- Update client combined metadata file [\#277](https://github.com/Accenture/kx.as.code/issues/277)
- Add description data to all metadata.json files [\#276](https://github.com/Accenture/kx.as.code/issues/276)
- Clean up old kx-external-access directory when redploying KX.AS.CODE [\#273](https://github.com/Accenture/kx.as.code/issues/273)

**Fixed bugs:**

- Launcher shows "null" on review page when 0 templates selected [\#286](https://github.com/Accenture/kx.as.code/issues/286)
- Jenkins launcher shows 0.8.9 newer than 0.8.10 [\#283](https://github.com/Accenture/kx.as.code/issues/283)
- Use localhost for external hosts file entries [\#274](https://github.com/Accenture/kx.as.code/issues/274)
- getGlobalVariables.sh: line 4: functionStart: command not found [\#272](https://github.com/Accenture/kx.as.code/issues/272)


## [v0.8.9](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.9) (2022-08-12)
The major focus for this release has been the upgrade of Kubernetes to v1.24, and adding the option to use K3s instead of K8s. See below for other enhancements and bug fixes.

**Implemented enhancements:**

- Improve logging and debugging [\#260](https://github.com/Accenture/kx.as.code/issues/260)
- Add mechanism to automatically pull latest KX.AS.CODE on first boot [\#258](https://github.com/Accenture/kx.as.code/issues/258)
- Upgrade MinIO and migrate from Helm chart to Operator [\#257](https://github.com/Accenture/kx.as.code/issues/257)
- Add K3s and startup mode options to Jenkins based launcher [\#256](https://github.com/Accenture/kx.as.code/issues/256)
- Migrate helper scripts to central callable functions [\#255](https://github.com/Accenture/kx.as.code/issues/255)
- Upgrade OpenLens to 6.0.0 [\#254](https://github.com/Accenture/kx.as.code/issues/254)
- Add NeuVector to application library [\#253](https://github.com/Accenture/kx.as.code/issues/253)
- Allow option to continue processing queue after a component installation fails [\#252](https://github.com/Accenture/kx.as.code/issues/252)
- Add option to use K3s instead of K8s [\#248](https://github.com/Accenture/kx.as.code/issues/248)
- Upgrade Kubernetes from v1.2.1 to v1.2.4 [\#247](https://github.com/Accenture/kx.as.code/issues/247)

**Fixed bugs:**

- CoreDNS not updating correctly with custom server after upgrade to 1.24 [\#259](https://github.com/Accenture/kx.as.code/issues/259)
- Block-device auto selection detected wrong drive [\#251](https://github.com/Accenture/kx.as.code/issues/251)
- SDDM greeter takes up 20% CPU when idle [\#250](https://github.com/Accenture/kx.as.code/issues/250)
- Polling script exits when child script returns RC != 0 [\#249](https://github.com/Accenture/kx.as.code/issues/249)
- Jenkins unable to start using launchLocalBuildEnvironment.ps1 script [\#225](https://github.com/Accenture/kx.as.code/issues/225)
